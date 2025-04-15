# devfile-registry

> [!WARNING]
> This repository has been retired and will no longer be maintained. It has been archived and will remain read-only.


Source repository for the Red Hat product devfile registry

This product devfile registry is updated weekly, by 12pm EST Wednesdays, with any updated stacks in this repository.

## Registry Updates

The staging product devfile registry is refreshed upon each commit to main in this repository. Production is promoted manually and as mentioned above, is done each Wednesday, as needed.

If you are a stack owner and need to request an urgent refresh of the registry service before Wednesday (for example if a stack is broken), please open an issue in this repository outlining the following:

- Stack name
- Why the refresh is needed
- Why the refresh cannot wait until the next regularly scheduled refresh

## Developing

### Prerequisites

- Docker 17.06 or later
- Git

### Build

To build this devfile registry into a container image run `.ci/build.sh`. A container image will be built using the [devfile registry build tools](https://github.com/devfile/registry-support/tree/master/build-tools).

From there, push the container image to a container registry of your choice and deploy using one of the methods outlined [here](https://github.com/devfile/registry-support#deploy).
