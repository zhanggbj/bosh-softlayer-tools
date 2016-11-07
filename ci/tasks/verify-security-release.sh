#!/usr/bin/env bash
set -e
source bosh-softlayer-tools/ci/tasks/utils.sh

bosh_cli=${BOSH_CLI}
bosh_cli_password=${BOSH_CLI_PASSWORD}
echo "copy scripts..."
#scripts="run.sh,run.user.expect,test-component.sh"
#sudo apt-get -y install expect
#set timeout 10
#/usr/bin/env expect<<EOF
#spawn scp -o StrictHostKeyChecking=no root@$bosh_cli:/root/security/\{${scripts}\} ./
#expect "*?assword:*"
#exp_send "$bosh_cli_password\r"
#expect eof
#EOF
#ls ./
#
#gem install bosh_cli --no-ri --no-rdo c
#
#echo "using bosh CLI version..."
#bosh version
#
#echo "login director..."
#bosh -n target ${BLUEMIX_DIRECTOR_IP}
#bosh login admin admin
#
#export BOSH_CLIENT=fake_client
#export BOSH_CLIENT_SECRET=fake_secret
#
#security_release_version=`curl http://10.106.192.96/releases/security-release/|tail -n 3|head -n 1|cut -d '"' -f 2|sed 's/\///g'`
#echo "DEBUG security_release_version is"${security_release_version}
##old_security_version=`bosh releases|grep security-release| awk '{print $4}'|sed 's/\*//g'`
##echo "DEBUG:old_security_version="$old_security_version
#echo "verify security release version..."
#bosh deployments | grep security-release/${security_release_version}
#if [ $? -ne 0 ]; then
#  echo "security release version is not correct"
#  exit 1
#fi
#
#
#echo "collect VM ip addresses..."
#bosh vms|awk '/running/{print $11}' > ipaddr.csv
#run_log="run.log"
#echo "run test-component.sh on all VMs..."
#./run.sh -s test-component.sh -i ipaddr.csv -p Paa54futur3 -a | tee $run_log
#sleep 3
#
#cat $run_log | grep "Error connecting to server"
#if [ $? -eq 0 ]; then
#   exit 1
#fi
#
#final_result=`awk '/secmon is/{nr[NR+1]}; NR in nr'  $run_log |awk '{ SUM += $1} END { print SUM }'`
#if [ $final_result -eq 0 ]; then
#  echo "Security Release Verification Pass..."
#  exit 0
#else
#  echo "Security Release Verification Fail..."
#  cat $run_log
#  exit 1
#fi