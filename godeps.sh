#!/bin/bash
set -e
set -o pipefail

FILE_NAME=$1

# Build godep-licenses image
git clone https://github.com/nghiant2710/godep-licenses.git
cd godep-licenses
docker build -t godep-licenses:latest .
cd -
rm -rf godep-licenses

# Extract licenses
git clone https://github.com/resin-io/resin-supervisor.git
cd resin-supervisor/gosuper
docker run --rm -i -v "$(pwd):/repo" godep-licenses:latest -p /repo -f "Resin Go Supervisor" -o md > $FILE_NAME
cd -
rm -rf resin-supervisor
