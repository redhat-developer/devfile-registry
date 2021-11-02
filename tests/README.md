# Product Devfile Registry Testing

## Prerequisites

- OpenShift installed, and running.
  - [CodeReady Containers](https://developers.redhat.com/products/codeready-containers/overview) is a good starting point if you don't want to install a full OpenShfit cluster.
- odo v2 or later.
- [yq](https://github.com/mikefarah/yq) v4.x

## Running the tests

1) Log in to a running OpenShift instance with `oc`.

2) From the root of this repository, run `tests/test.sh`. 
  
    - The test script will validate each devfile stack under `stacks/` with odo, verifying that the stack can be used to build a starter project and that the application is properly built and exposed. 
       - The test script checks for an HTTP 200 status code to determine "properly exposed".
    - Each devfile stack **must** have at least one starter project specified in the devfile.yaml
      - **Note:** The script will use `yq` to find the name of the first starter project and download it. 

## Configuration:

- Set `STACK=<path-to-stack-folder>` if you only want to test one specific test (rather than all of the stacks in this repository). 
  - e.g. `STACK=stacks/java-jboss-eap-xp ./tests/test.sh`

## Limitations

- If there are multiple starter projects, odo will only use the first starter project mentioned.
- Only `odo create`,  `odo url create`, and `odo push` are tested right now. If your devfile stack exposes additional functionality (such as debug, via `odo debug`), we recommend either manually testing that functionality, or setting up your own test scripts in the stack's repository