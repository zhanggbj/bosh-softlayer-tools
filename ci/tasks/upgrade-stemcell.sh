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
bosh_cli=${BOSH_CLI}
bosh_cli_password=${BOSH_CLI_PASSWORD}
old_stemcell_version=`bosh stemcells|grep bosh-softlayer-xen-ubuntu-trusty-go_agent|awk '{print $6}'|sed 's/\*//g'`
echo "DEBUG:old_stemcell_version="$old_stemcell_version

echo "upload new stemcell..."
ls ./stemcell/
bosh upload stemcell ./stemcell/light-bosh-stemcell-*.tgz --skip-if-exists
new_stemcell_version=`ls ./stemcell|grep light-bosh-stemcell| cut -d "-" -f 4`
echo "DEBUG:new_stemcell_version="$new_stemcell_version

old_security_version=`bosh releases|grep security-release| awk '{print $4}'`
echo "DEBUG:old_security_version="$old_security_version
new_security_version=`curl http://10.106.192.96/releases/security-release/|tail -n 3|head -n 1|cut -d '"' -f 2|sed 's/\///g'`
echo "DEBUG:new_security_version="$new_security_version
#for DEBUG
#mkdir security-release
#wget http://10.106.192.96/releases/security-release/${new_security_version}/security-release.tgz -P ./security-release/
#bosh upload release ./security-release/security-release.tgz --skip-if-exists

echo "copy deployment yml..."
sudo apt-get -y install expect
set timeout 30
deployment_yml="gen-cf-release-public-spruce-template-ppl.yml"
/usr/bin/env expect<<EOF
spawn scp -o StrictHostKeyChecking=no root@$bosh_cli:/root/v1/${deployment_yml} ./
expect "*?assword:*"
exp_send "$bosh_cli_password\r"
expect eof
EOF

echo "Update deployment yml..."
sed -i '/stemcell_version=/s/${old_stemcell_version}/${new_stemcell_version}/' ./${deployment_yml}
sleep 3
sed -i '/security-release.tgz/n;N;N;s/${old_security_version}/${new_security_version}/' ./${deployment_yml}

echo "backup deployment yml..."
/usr/bin/env expect<<EOF
spawn scp -o StrictHostKeyChecking=no -r ./${deployment_yml} root@$bosh_cli:/root/v1/
expect "*?assword:*"
exp_send "$bosh_cli_password\r"
expect eof
EOF

echo "set deployment..."
bosh deployment ${deployment_yml}

echo "upgrade stemcell and security-release..."
echo "yes" | bosh deploy

echo "DEBUG: bosh deploy result="$?
bosh tasks