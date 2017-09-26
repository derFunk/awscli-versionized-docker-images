#!/bin/bash

PUSH_EXISTING=${PUSH_EXISTING:-false}
REPO=derfunk/awscli-versionized

echo "Creating local base image..."
docker build --pull --force-rm -t awscli-versionized-base:latest -f Dockerfile.base .

# Get all versioned aws cli tags uploaded already available 
i="1"
echo -n > awscli-versioned-versions.txt
while true; do
	echo "Fetching page ${i} of already existing versionized aws cli tags..."
	if ! curl -fs -o awscli-versioned-tmp.json https://hub.docker.com/v2/repositories/${REPO}/tags/\?page_size\=100\&page\=${i}; then
		echo "Page ${i} did not exist anymore, continuing..."
		break;
	fi
	jq -r ".results | .[].name" awscli-versioned-tmp.json | grep "\d\+.\d\+.\d\+" >> awscli-versioned-versions.txt
	i=$[$i+1]
done
rm -f awscli-versioned-tmp.json

# Get current .changes tree SHA
JSON_MASTER=$(curl -fs https://api.github.com/repos/aws/aws-cli/git/trees/master)
CHANGES_JSON_URL=$(echo ${JSON_MASTER} | jq -r '.tree[] | select(.path==".changes" and .type=="tree") | .url')

# Get all official aws cli versions 
JSON_CHANGES=$(curl -fs ${CHANGES_JSON_URL})
echo ${JSON_CHANGES} | jq -r ".tree | .[].path" | grep "\d\+.*\.json" | sed "s/\.json//g" > awscli-versions.txt

cat awscli-versions.txt | while read version
do
	# only push to the versioned aws cli repo if it's not available online yet
	if [ "${PUSH_EXISTING}" = "true" ] || ! grep -q "^${version}$" awscli-versioned-versions.txt; then
		echo "Building and pushing aws-cli version ${version}..."
    	docker build --build-arg AWSCLI_VERSION=${version} -t ${REPO}:${version} -f Dockerfile .
    	docker push ${REPO}:${version} && docker rmi ${REPO}:${version}
    else
    	echo "Not pushing aws-cli version ${version} because it's already present."
    fi
done

echo "Cleaning up..."
docker rm -f awscli-versionized-base:latest || true
