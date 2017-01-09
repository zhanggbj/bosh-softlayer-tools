#!/usr/bin/env bash
set -ex

dir=`dirname "$0"`
source ${dir}/upgrade-environment.sh
source ${dir}/utils.sh

deployment_yml="gen-cf-release-public-spruce-template-ppl.yml"

bosh_cli=${BOSH_CLI}
bosh_cli_password=${BOSH_CLI_PASSWORD}
install_bosh_cli
echo "login director..."
bosh -n target ${BLUEMIX_DIRECTOR_IP}
bosh login admin admin

set timeout 30
/usr/bin/env expect<<EOF
spawn scp -o StrictHostKeyChecking=no root@$bosh_cli:/root/security/${deployment_yml} ./
expect "*?assword:*"
exp_send "$bosh_cli_password\r"
expect eof
EOF

bosh_deploy