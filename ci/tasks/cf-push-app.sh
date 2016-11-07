#!/usr/bin/env bash
set -e -x
curl -L "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" | tar -zx
mv cf /usr/local/bin
echo "cf version..."
cf --version

sed -i '1 i\nameserver 10.113.205.104' /etc/resolv.conf
CF_TRACE=true cf api http://api.gubinpreyf3.ng.bluemix.net
CF_TRACE=true cf login -u ibmadmin@us.ibm.com -p Passw0rd
base=`dirname "$0"`
cf push IICVisit -p ${base}/ci/tasks/IICVisit.war
curl iicvisit.gubinpreyf3.mybluemix.net/GetEnv