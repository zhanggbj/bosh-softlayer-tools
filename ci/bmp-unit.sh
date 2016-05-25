#!/usr/bin/env bash

set -e

go version

echo "GOPATH 0 " $GOPATH
base=$( cd "$( dirname "$( dirname "$0" )")" && pwd )
echo "base is" $base
base_gopath=$( cd $base/../../../.. && pwd )
echo "base gopath is" $base_gopath

export GOPATH=$base/Godeps/_workspace:$base_gopath:$GOPATH

echo "GOPATH 2 " $GOPATH


function printStatus {
      if [ $? -eq 0 ]; then
          echo -e "\nSWEET SUITE SUCCESS"
      else
          echo -e "\nSUITE FAILURE"
      fi
  }

  trap printStatus EXIT
#  export GOPATH=$(godep path):$GOPATH

  export BMP_UT_OUTPUT=False

  echo -e "\n Cleaning build artifacts..."
  go clean

  echo -e "\n Formatting packages..."
  go fmt ./...

  echo -e "\n Unit Testing packages:"
  ginkgo -r -p --noisyPendings --skipPackage=integration

  echo -e "\n Vetting packages for potential issues..."
  go tool vet main config cmds common integration


