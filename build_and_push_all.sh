#!/bin/bash

PUSH_EXISTING=${PUSH_EXISTING:-false}
REPO=derfunk/awscli-versionized

# Get all versioned aws cli tags uploaded already available 
i="1"
echo -n > awscli-versioned-versions.txt
while true; do
	echo "Fetching page ${i} of existing versionized aws cli tags..."
	if ! curl -fs -o awscli-versioned-tmp.json https://hub.docker.com/v2/repositories/${REPO}/tags/\?page_size\=100\&page\=${i}; then
		echo "Page ${i} did not exist anymore, continuing..."
		break;
	fi
	jq -r ".results | .[].name" awscli-versioned-tmp.json | grep "\d\+.\d\+.\d\+" >> awscli-versioned-versions.txt
	i=$[$i+1]
done
rm -f awscli-versioned-tmp.json

# Get all official aws cli versions 
curl -fs -o awscli-changes.json https://api.github.com/repos/aws/aws-cli/git/trees/fb9089827fea2fe4d79daf8063380913e2aa7dbf
jq -r ".tree | .[].path" awscli-changes.json | grep "\d\+.*\.json" | sed "s/\.json//g" > awscli-versions.txt
rm -f awscli-changes.json

cat awscli-versions.txt | while read version
do
	# only push to the versioned aws cli repo if it's not available online yet
	if [ "${PUSH_EXISTING}" = "true" ] || ! grep -q "^${version}$" awscli-versioned-versions.txt; then
		echo "Building and pushing aws-cli version ${version}..."
    	docker build --build-arg AWSCLI_VERSION=${version} -t ${REPO}:${version} .
    	docker push ${REPO}:${version}
    else
    	echo "Not pushing aws-cli version ${version} because it's already present."
    fi
done
