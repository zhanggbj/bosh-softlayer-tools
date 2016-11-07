#!/usr/bin/env bash
set -e -x

dir=`dirname "$0"`
source ${dir}/utils.sh

print_title INSTALL CF CLI...
curl -L "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" | tar -zx
mv cf /usr/local/bin
echo "cf version..."
cf --version

print_title CF PUSH APP...
sed -i '1 i\nameserver 10.113.205.104' /etc/resolv.conf
CF_TRACE=true cf api http://api.gubinpreyf3.ng.bluemix.net
CF_TRACE=true cf login -u ibmadmin@us.ibm.com -p Passw0rd
base=`dirname "$0"`
cf push IICVisit -p ${base}/IICVisit.war
curl iicvisit.gubinpreyf3.mybluemix.net/GetEnv|grep "DEA IP"
if [ $? -eq 0 ]; then
   echo "cf push app successful!"
fi