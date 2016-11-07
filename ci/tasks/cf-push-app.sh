#!/usr/bin/env bash
sed -i '1 i\nameserver 10.113.205.104' /etc/resolv.conf
CF_TRACE=true cf api http://api.gubinpreyf3.ng.bluemix.net
CF_TRACE=true cf login -u ibmadmin@us.ibm.com -p Passw0rd
cf push IICVisit -p ./ci/tasks/IICVisit.war
curl iicvisit.gubinpreyf3.mybluemix.net/GetEnv