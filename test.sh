#!/bin/bash 
set -e +x
base=$( cd "$( dirname "$( dirname "$0" )")" && pwd )
base_gopath=$( cd $base/../../../.. && pwd )
export GOPATH=$base/Godeps/_workspace:$base_gopath:$GOPATH
