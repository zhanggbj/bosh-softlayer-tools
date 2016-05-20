#!/usr/bin/env bash

set -e

go version
go get github.com/tools/godep
go get github.com/onsi/ginkgo/ginkgo
go get github.com/golang/go/src/cmd/vet
go get github.com/onsi/gomega

echo $PWD

echo "run ut"

./gopath/src/github.com/zhanggbj/bosh-softlayer-tools/bin/test-unit
