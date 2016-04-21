#!/bin/bash
set -e
set -o pipefail

# Base on awesome script here: https://gist.github.com/cjus/1047794
function extract_json_value() {
	# key
	key=$1
	# number of value we want to get if it's multiple value
	num=$2
	awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$key'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p
}

if [ -f package.json ]; then
	npm ls --json | extract_json_value 'from' > npm.deps
	while read package
	do
		printf "Package: %s - License: %s \n" "$package" "$(npm show $package license | tr '\n' ', ')" >> npm.content
	done < npm.deps
	cp -f npm.deps npm.content /output/
fi

if [ -f bower.json ]; then
	apt-get update && apt-get install -y jq
	npm install -g bower-license
	bower-license -e json | jq 'to_entries[] | {(.key): .value | .licenses } | tostring' | tr -d '{}[]"\\' > bower.deps
	while read line
	do
		IFS=$':' read -r -a entry <<< "$line"
		package="${entry[0]}"
		license="${entry[1]}"
		printf "Package: %s - License: %s \n" "$package" "$license" >> bower.content
	done < bower.deps
	cp -f bower.deps bower.content /output/
fi
