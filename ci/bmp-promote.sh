#!/usr/bin/env bash

set -e -x

#source bosh-cpi-release/ci/tasks/utils.sh
#
#check_param S3_ACCESS_KEY_ID
#check_param S3_SECRET_ACCESS_KEY
#
#source /etc/profile.d/chruby.sh
#chruby 2.1.2

# Creates an integer version number from the semantic version format
# May be changed when we decide to fully use semantic versions for releases

version=`cat version-semver/number`
echo $version > promoted/version

echo "PWD is" $PWD
ls -al

base=$( cd "$( dirname "$( dirname "$0" )")" && pwd )

base_gopath=$( cd $base/../../../.. && pwd )

export GOPATH=$base/Godeps/_workspace:$base_gopath:$GOPATH

echo "GOPATH=" $GOPATH

cd $base

echo -e "\nGenerating Binary: bmp..."
go build -o out/bmp-$version main/bmp/bmp.go
chmod +x out/bmp-$version

cp out/bmp-$version promoted/bmp-$version

