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

version="0.0.1"
#echo $version > promoted/version

echo -e "\nGenerating Binary: bmp..."
go build -o $(dirname $0)/../out/bmp-$version ./main/bmp/bmp.go
chmod +x out/bmp-$version

cp out/bmp-$version promoted/repo


pushd promoted/repo
  set +x
  echo creating config/private.yml with blobstore secrets
  cat > config/private.yml << EOF
---
blobstore:
  s3:
    access_key_id: $S3_ACCESS_KEY_ID
    secret_access_key: $S3_SECRET_ACCESS_KEY
EOF
  rm config/private.yml
popd


