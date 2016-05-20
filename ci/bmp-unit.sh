#!/usr/bin/env bash

set -e

go get github.com/tools/godep
go get github.com/onsi/ginkgo/ginkgo
go get github.com/onsi/gomega

echo "run ut"
./bosh-softlayer-tools/bin/test-unit
