#!/usr/bin/env bash
set -e

dir=`dirname "$0"`
source ${dir}/utils.sh

bosh_cli=${BOSH_CLI}
bosh_cli_password=${BOSH_CLI_PASSWORD}

install_bosh_cli
echo "login director..."
bosh -n target ${BLUEMIX_DIRECTOR_IP}
bosh login admin admin

prepare_scripts

verify_security_release_version

verify_security_release_on_vm

func prepare_scripts (){
print_title "PREPARE SCRIPTS..."
scripts="run.sh,run.user.expect,test-component.sh"
sudo apt-get -y install expect
set timeout 10
/usr/bin/env expect<<EOF
spawn scp -o StrictHostKeyChecking=no root@$bosh_cli:/root/security/\{${scripts}\} ./
expect "*?assword:*"
exp_send "$bosh_cli_password\r"
expect eof
EOF
}

func verify_security_release_version (){
print_title "VERIFY SECURITY RELEASE VERSION..."
security_release_version=`curl http://10.106.192.96/releases/security-release/|tail -n 3|head -n 1|cut -d '"' -f 2|sed 's/\///g'`
echo "DEBUG security_release_version is"${security_release_version}

echo "verify security release version..."
bosh deployments | grep security-release/${security_release_version}
if [ $? -ne 0 ]; then
  echo "security release version is not correct"
  exit 1
fi
}

func verify_security_release_on_vm (){
print_title "VERIFY SECURITY RELEASE ON VM..."
echo "collect all VM ip addresses..."
bosh vms|awk '/running/{print $11}' > ipaddr.csv
run_log="run.log"
echo "run test-component.sh on all VMs..."
./run.sh -s test-component.sh -i ipaddr.csv -p Paa54futur3 -a | tee $run_log
sleep 3

cat $run_log | grep "Error connecting to server"
if [ $? -eq 0 ]; then
   exit 1
fi

final_result=`awk '/secmon is/{nr[NR+1]}; NR in nr'  $run_log |awk '{ SUM += $1} END { print SUM }'`
if [ $final_result -eq 0 ]; then
  echo "Security release verification pass..."
  exit 0
else
  echo "Security release verification fail..."
  exit 1
fi

print_title "SECURITY RELEASE VERIFICATION DETAILs..."
cat $run_log
}
