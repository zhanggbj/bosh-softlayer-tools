#!/usr/bin/env bash

set -e

base=$( cd "$( dirname "$( dirname "$0" )")"/.. && pwd )
base_gopath=$( cd $base/../../../.. && pwd )
go version
go get -t -v  github.com/onsi/ginkgo/ginkgo
export GOPATH=$base_gopath:$GOPATH
echo "GOPATH=" $GOPATH

echo "installing bosh CLI"
gem install bosh_cli --no-ri --no-rdo c

echo "using bosh CLI version..."
bosh version

echo "login director..."
bosh -n target ${BLUEMIX_DIRECTOR_IP}
bosh login admin admin

export BOSH_CLIENT=fake_client
export BOSH_CLIENT_SECRET=fake_secret

echo "list vms..."
bosh vms

echo "list stemcells"
bosh stemcells

echo "update stemcell version..."
bosh_client=${BOSH_CLIENT}
bosh_client_password=${BOSH_CLIENT_PASSWORD}
old_stemcell_version=`bosh stemcells|grep bosh-softlayer-xen-ubuntu-trusty-go_agent|awk '{print $6}'|sed 's/\*//g'`
echo "DEBUG:old_stemcell_version="$old_stemcell_version

echo "upload new stemcell..."
bosh upload stemcell ./stemcell/light-bosh-stemcell-*.tgz
new_stemcell_version=`ls ./stemcell|cut -d "-" -f 3`
echo "DEBUG:new_stemcell_version="$new_stemcell_version

old_security_version=`bosh releases|grep security-release| awk '{print $4}'`
echo "DEBUG:old_security_version="$old_security_version
new_security_version=`curl http://10.106.192.96/releases/security-release/|tail -n 3|head -n 1|cut -d '"' -f 2|sed 's/\///g'`
echo "DEBUG:new_security_version="$new_security_version

sudo apt-get -y install expect
set timeout 30
/usr/bin/env expect<<EOF
spawn ssh -o StrictHostKeyChecking=no root@bosh_client
expect "*?assword:*"
exp_send "$bosh_client_password\r"
sleep 5
send "sed -i '/stemcell_version=/s/$/stemcell_verion=$new_stemcell_version/' /root/v1/gen-cf-release-public-spruce-template-ppl.yml\r"
sleep 3
send "sed -i '/security-release.tgz/n;N;N;s/${old_security_version}/$new_stemcell_version/' /root/v1/gen-cf-release-public-spruce-template-ppl.yml\r"
expect eof
EOF

echo "upgrade stemcell and security-release..."
echo "yes" | bosh deploy