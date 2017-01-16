#!/bin/bash

  set -e

  # outputs
  output_dir="light-stemcell"
  mkdir -p ${output_dir}

  echo -e "\n Get stemcell version..."
  stemcell_version=$(cat version/number | sed 's/\.0$//;s/\.0$//')

  base=$( cd "$( dirname "$( dirname "$( dirname "$0" )")")" && pwd )
  base_gopath=$( cd $base/../../../.. && pwd )

  export GOPATH=$base_gopath:$GOPATH

  echo -e "\n Creating stemcell binary..."
  cd "${base}"
  go build -o out/sl_stemcells main/stemcells/stemcells.go

  echo -e "\n Softlayer creating light stemcell..."
  out/sl_stemcells -c light-stemcell --version ${stemcell_version} --stemcell-info-filename "${base_gopath}/../stemcell-info/stemcell-info.json"

  cp *.tgz "${base_gopath}/../${output_dir}/"

  stemcell_filename=`ls light*.tgz`

  checksum="$(sha1sum "${base_gopath}/../${output_dir}/${stemcell_filename}" | awk '{print $1}')"
  echo "$stemcell_filename sha1=$checksum"