#!/usr/bin/env bash

set -e -x

version=`cat version-semver/number`
echo $version > promoted/version

base=$( cd "$( dirname "$( dirname "$0" )")" && pwd )

base_gopath=$( cd $base/../../../.. && pwd )

export GOPATH=$base/Godeps/_workspace:$base_gopath:$GOPATH

echo "GOPATH=" $GOPATH

echo -e "\nGenerating Binary: bmp..."
go build -o $base/out/bmp-$version $base/main/bmp/bmp.go
chmod +x $base/out/bmp-$version

mv $base/out/bmp-$version promoted/

