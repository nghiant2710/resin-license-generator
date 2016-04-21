#!/bin/bash
set -e
set -o pipefail

IMAGE_LIST='amd64-supervisor resin-api resin-builder resin-delta resin-proxy resin-git resin-img resin-registry resin-registry2 resin-ui resin-admin'
DATE=$(date +'%Y%m%d' -u)
FILE_NAME=resin-service-dependency-list-$DATE
GO_SUPER_FILE_NAME=resin-go-supervisor-dependency-list-$DATE

# NPM and Bower
rm -rf $FILE_NAME
touch $FILE_NAME
for image in $IMAGE_LIST; do
	rm -rf "$image"
	mkdir "$image"
	cp npm-bower-parser.sh "$image/"
	if [ $image == "resin-img" ]; then
		image_tag='master-slim'
	else
		image_tag='master'
	fi
	docker run --rm -v `pwd`"/$image":/output --entrypoint=/output/npm-bower-parser.sh "resin/$image:$image_tag"

	echo "==========$image==========" >> $FILE_NAME
	if [ -f "$image/npm.content" ]; then
		echo "-----NPM Dependencies-----" >> $FILE_NAME
		cat "$image/npm.content" >> $FILE_NAME
	fi
	if [ -f "$image/npm.content" ]; then
		echo "-----Bower Dependencies-----" >> $FILE_NAME
		cat "$image/bower.content" >> $FILE_NAME
	fi
	echo $'\n' >> $FILE_NAME
done

# Go Deps
bash godeps.sh "$(pwd)/$GO_SUPER_FILE_NAME"
