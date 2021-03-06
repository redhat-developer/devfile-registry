#!/bin/sh

set -x
DEVFILES_DIR="$(pwd)/stacks/"
FAILED_TESTS=""

getURLs() {
    urls=$($ODO_PATH url list | awk '{ print $3 }' | tail -n +3 | tr '\n' ' ')
    echo "$urls"
}

# periodicaly check url till it returns expected HTTP status
# exit after 10 tries
waitForHTTPStatus() {
   url=$1
   statusCode=$2

    for i in $(seq 1 10); do
        echo "try: $i"
        content=$(curl -i "$url")
        echo "Checking if $url is returning HTTP $statusCode"
        echo "$content" | grep -q -E "HTTP/[0-9.]+ $statusCode"
        retVal=$?
        if [ $retVal -ne 0 ]; then
            echo "ERROR not HTTP $statusCode"
            echo "$content"
        else
            echo "OK HTTP $statusCode"
            return 0
        fi
        sleep 10
    done
    return 1
}

# run test on devfile
# parameters:
# - name of a component and project 
# - path to devfile.yaml
test() {
    devfileName=$1
    devfilePath=$2

    # remember if there was en error
    error=false

    tmpDir=$(mktemp -d)
    cd "$tmpDir" || return 1

    $ODO_PATH project create "$devfileName" || error=true
    if $error; then
        echo "ERROR odo project create failed"
        FAILED_TESTS="$FAILED_TESTS $devfileName"
        return 1
    fi
    
    # Get the starter project name
    starterProject=$($YQ_PATH e '.starterProjects[0].name' $devfilePath)
    if [ "$REGISTRY" = "local" ]; then
      $ODO_PATH create "$devfileName" --devfile "$devfilePath" --starter $starterProject || error=true
    else
      $ODO_PATH create "$devfileName" --starter $starterProject || error=true
    fi

    if $error; then
        echo "ERROR odo create failed"
        $ODO_PATH project delete -f "$devfileName"
        FAILED_TESTS="$FAILED_TESTS $devfileName"
        return 1
    fi

    if [ "$ENV" = "minikube" ]; then
        # ToDo: Clean up, I'm not happy about having specific checks for the stacks with multiple ports
        # But since we're testing against minikube, we need to specifically create the URL/ingress before pushing
        # And if there's multiple ports in the devfile, a port must be specified.
        if [ "$devfileName" = "java-wildfly" ] || [ "$devfileName" = "java-wildfly-bootable-jar" ]; then
            $ODO_PATH url create --host "$(minikube ip).nip.io" --port 8080 || error=true
            $ODO_PATH url create --host "$(minikube ip).nip.io" --port 16686 || error=true
        else
            $ODO_PATH url create --host "$(minikube ip).nip.io" || error=true
        fi
        if $error; then
            echo "ERROR odo url create failed"
            $ODO_PATH project delete -f "$devfileName"
            FAILED_TESTS="$FAILED_TESTS $devfileName"
            return 1
        fi
    fi

    $ODO_PATH push || error=true
    if $error; then
        echo "ERROR odo push failed"
        $ODO_PATH delete -f -a || error=true
        $ODO_PATH project delete -f "$devfileName"
        FAILED_TESTS="$FAILED_TESTS $devfileName"
        return 1
    fi

    # check if application is responding
    urls=$(getURLs)

    for url in $urls; do
        statusCode=200
        
        waitForHTTPStatus "$url" "$statusCode"
        if [ $? -ne 0 ]; then
            echo "ERROR unable to get working url"
            $ODO_PATH project delete -f "$devfileName"
            FAILED_TESTS="$FAILED_TESTS $devfileName"
            error=true
            return 1
        fi
    done

    # kill -9 $CPID
    $ODO_PATH delete -f -a || error=true
    $ODO_PATH project delete -f "$devfileName"

    if $error; then
        echo "FAIL"
        # record failed test
        FAILED_TESTS="$FAILED_TESTS $devfileName"
        return 1
    fi

    return 0
}

if [ -z $ODO_PATH ]; then
  ODO_PATH=odo
fi
if [ -z $YQ_PATH ]; then
  YQ_PATH=yq
fi

if [ -z $REGISTRY ]; then
  REGISTRY=local
fi
if [ "$REGISTRY" != "local" ] && [ "$REGISTRY" != "remote" ]; then
  echo "ERROR: Allowed values for REGISTRY are either \"local\" (default) or \"remote\"."
  exit 1
fi


# If $STACK is set, test only that specific stack
# Otherwise, test the other stacks.
if [ $STACK ]; then
  stackFolder="$(realpath $(dirname $STACK))"
  devfile_name="$(basename $STACK)"
  devfile_path=$stackFolder/$devfile_name/devfile.yaml
  test "$devfile_name" "$devfile_path"
else
  for devfile_dir in $(find $DEVFILES_DIR -maxdepth 1 -type d ! -path $DEVFILES_DIR); do
      devfile_name="$(basename $devfile_dir)"
      devfile_path=$devfile_dir/devfile.yaml

      test "$devfile_name" "$devfile_path"
  done
fi

# print out which tests failed
if [ "$FAILED_TESTS" != "" ]; then
    echo "FAILURE: FAILED TESTS: $FAILED_TESTS"
    exit 1
fi

exit 0
