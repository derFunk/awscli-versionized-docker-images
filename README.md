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
For pushed AWS CLI image tags see [awscli-versioned-versions.txt](awscli-versioned-versions.txt) or https://cloud.docker.com/repository/registry-1.docker.io/derfunk/awscli-versionized/tags.
