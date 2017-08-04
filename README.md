## Building and pushing versionized AWS CLI images
Execute `./build_and_push_all.sh`.
Log in to the Docker registry before (in this case: mine (derfunk)).

## Example of how to use it
```
$ docker run --rm derfunk/awscli-versionized:1.11.45 aws --v
aws-cli/1.11.45 Python/2.7.12 Linux/4.9.36-moby botocore/1.5.8
```
## Images on Docker Hub

 - https://hub.docker.com/r/derfunk/awscli-versionized/

### Available AWS CLI version tags
Docker Hub still does not support pagination on the tags page, so there's more than you'd actually see. (see also https://github.com/docker/hub-feedback/issues/194).

For pushed AWS CLI image tags see [awscli-versioned-versions.txt](awscli-versioned-versions.txt).
