#!/usr/bin/env bash

PUSH_EXISTING=${PUSH_EXISTING:-false}
REPO=derfunk/awscli-versionized

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
echo ${JSON_CHANGES} | jq -r ".tree | .[].path" | grep "\d\+.*\.json" | sed "s/\.json//g" > awscli-versions_unsorted.txt

# Sort versions
sort -t. -k 1,1nr -k 2,2nr -k 3,3nr -k 4,4nr awscli-versions_unsorted.txt > awscli-versions.txt
rm awscli-versions_unsorted.txt

BASE_BUILT=false
LATEST_TAGGED=false

while read version
do

    # We now that awscli version 1.10.55 is broken in pip.
    if [ "${version}" = "1.10.55" ]; then continue; fi

	# only push to the versioned aws cli repo if it's not available online yet
	if [ "${PUSH_EXISTING}" = "true" ] || ! grep -q "^${version}$" awscli-versioned-versions.txt; then

        if [ "${BASE_BUILT}" = "false" ]; then
            echo "Creating local base image..."
            docker build --pull --force-rm -t awscli-versionized-base:latest -f Dockerfile.base .
            BASE_BUILT=true 
        fi
		
        echo "Building and pushing aws-cli version ${version}..."

    	docker build --compress --build-arg AWSCLI_VERSION=${version} -t ${REPO}:${version} -f Dockerfile .
    	docker push ${REPO}:${version} && docker rmi ${REPO}:${version}
        
        if [ "${LATEST_TAGGED}" = "false" ]; then
            # After we sorted the versions file, we know that the first version in it must be the latest version.
            docker tag ${REPO}:${version} ${REPO}:latest \
                && docker push ${REPO}:latest \
                && docker rmi ${REPO}:latest
            LATEST_TAGGED=true
        fi
    else
    	echo "Not pushing aws-cli version ${version} because it's already present."
    fi
done <<< $(cat awscli-versions.txt)

if [ "${BASE_BUILT}" = "true" ]; then
    echo "Cleaning up..."
    docker rmi -f awscli-versionized-base:latest || true
fi
