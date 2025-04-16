# devfile-registry

> [!WARNING]
> This repository has been retired and will no longer be maintained. It has been archived and will remain read-only.

## Developing

### Prerequisites

- Docker 17.06 or later
- Git

### Build

To build this devfile registry into a container image run `.ci/build.sh`. A container image will be built using the [devfile registry build tools](https://github.com/devfile/registry-support/tree/master/build-tools) up until commit [4bc237b](https://github.com/devfile/registry-support/commit/4bc237b077e1bd478ea24195fac7c35fd2975441).

From there, push the container image to a container registry of your choice and deploy using one of the methods outlined [here](https://github.com/devfile/registry-support#deploy).
