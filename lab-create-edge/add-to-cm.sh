#!/bin/bash

. setup-env.sh

function call-cm() {
echo -e $3
    retval=`curl -sS -k -L --post302 -X $1 -H "Content-Type:application/json" -u $CM_ADMIN_USER:$CM_ADMIN_PASSWORD -d "$3" "https://$CM_IP:7183/api/v32/$2"`
    #retval=`curl -sS -k -L --post302 -X $1 -H "Content-Type:application/json" -u $CM_ADMIN_USER:$CM_ADMIN_PASSWORD -d @- "https://$CM_IP:7183/api/v32/$2"`
    echo $retval
}
# get hosts
# call-cm GET clusters/$CLUSTER/hosts ""

# add host
#PRIVATE_KEY_STR=$(cat $PRIVATE_KEY | tr -d '\n')


#PRIVATE_KEY_STR=$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' $PRIVATE_KEY)
PRIVATE_KEY_STR=$(awk '{printf "%s\\n", $0}' $PRIVATE_KEY)

call-cm POST cm/commands/hostInstall \
"{
  \"hostNames\" : [ \"$EDGE_FQDN\" ],
  \"sshPort\" : 22,
  \"userName\" : \"opc\",
  \"privateKey\" : \"$PRIVATE_KEY_STR\",
  \"passphrase\" : \"\",
  \"parallelInstallCount\" : 1,
  \"cmRepoUrl\" : \"\",
  \"gpgKeyCustomUrl\" : \"\",
  \"javaInstallStrategy\" : \"NONE\",
  \"unlimitedJCE\" : false,
  \"gpgKeyOverrideBundle\" : \"\"
}"