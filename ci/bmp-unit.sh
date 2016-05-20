#!/usr/bin/env bash

set -e

go version

go get github.com/tools/godep
go get github.com/onsi/ginkgo/ginkgo
go get github.com/golang/go/src/cmd/vet
go get github.com/onsi/gomega

echo "PWD is " + $PWD


function printStatus {
      if [ $? -eq 0 ]; then
          echo -e "\nSWEET SUITE SUCCESS"
      else
          echo -e "\nSUITE FAILURE"
      fi
  }

  trap printStatus EXIT
  export GOPATH=$(godep path):$GOPATH

  export BMP_UT_OUTPUT=False

  echo -e "\n Cleaning build artifacts..."
  go clean

  echo -e "\n Formatting packages..."
  go fmt ./...

  echo -e "\n Unit Testing packages:"
  ginkgo -r -p --noisyPendings --skipPackage=integration

  echo -e "\n Vetting packages for potential issues..."
  go tool vet main config cmds common integration


