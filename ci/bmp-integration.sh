#!/usr/bin/env bash

set -e

go version

base=$( cd "$( dirname "$( dirname "$0" )")" && pwd )

base_gopath=$( cd $base/../../../.. && pwd )

export GOPATH=$base/Godeps/_workspace:$base_gopath:$GOPATH

echo "GOPATH=" $GOPATH

function printStatus {
    if [ $? -eq 0 ]; then
        echo -e "\nSWEET SUITE SUCCESS"
    else
        echo -e "\nSUITE FAILURE"
    fi
}

trap printStatus EXIT

echo -e "\n Cleaning build artifacts..."
go clean

echo -e "\n Formatting packages..."
go fmt ./...

echo -e "\n cd to base of project..."
cd $base

echo "Using Baremetal Server:" $TARGET_URL
ping -c 3 10.113.189.114

config_file="~/.bmp_config"
cat "{}" >  ${config_file}

echo -e "\n Integration Testing packages:"
ginkgo -r -p -v --noisyPendings integration

echo -e "\n Vetting packages for potential issues..."
go tool vet main common cmds integration