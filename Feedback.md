# Feedback from tutorial

* Use DNS?
* Refer to user creation in the section on create bastion
* Failure accessing the repo
    * check ports
    * do we have the right node specified?
    * Clarify where to copy the repo file from
    * Is there a way to simplify???

EMEA Team

Before you begin, please check -

The quick start series:
[https://martygubar.github.io/bds-getting-started/](https://martygubar.github.io/bds-getting-started/)

FAQ:
[https://confluence.oraclecorp.com/confluence/display/BDSCSQL/FAQ](https://confluence.oraclecorp.com/confluence/display/BDSCSQL/FAQ)

* Use this link to have direct connect to OCI (this is pre-prod enviroment):
 [http://surl.us.oracle.com/bigdata_preprod_latest](http://surl.us.oracle.com/bigdata_preprod_latest)

You’ll need to be inside the Oracle network to use this URL. It is a shortcut to a much longer preprod URL. Preprod updates a couple of times per week and the URL changes. This URL consistently points to the latest.
* Use “oraclebigdatadb” tenancy
* Login/password: emea_team/emea.bds.Password1

* Use “bds-e2e” compartment (only)
* bdsKey and bdsKey.pub are the keys for OCI service (in the attachment)
* in order to get ssh access you have to jump on bastion host first:
ssh to bastion host:
ssh -i bdsKey [opc@129.213.43.37](mailto:opc@129.213.43.37)
* after this you can ssh to cluster host:
  ssh -i id_rsa [opc@10.200.13.187](mailto:opc@10.200.13.187)
* OCI has limit of 50 public IPs per tenancy. This is the reason why we don’t assign IP to each host.
* In a future we will allow to do this with OCI console, today there are some manula steps have to be done: [https://confluence.oci.oraclecorp.com/display/BDSOCI/Public+IP+Assignment+and+Un-assignment+On+OCI](https://confluence.oci.oraclecorp.com/display/BDSOCI/Public+IP+Assignment+and+Un-assignment+On+OCI)

For your Cluster you already have:
150.136.157.209 pmmigramn0
150.136.193.160 pmmigramn1
150.136.157.228 pmmigramn1

* CM:
 [https://150.136.157.228:7183/cmf/login](https://150.136.157.228:7183/cmf/login)
admin/Welcome1
* To get Kerberos credentials (any cluster node): kinit oracle
welcome1

if you want to test cluster provisioning, you can do it.
But I would like to ask you to destroy clusters right after you create and play around. Otherwise we may hit the case when this hardware can’t be reused by some certification teams, which will postpone our release.
For master nodes, please use StandardVM2.4. for Workers please use StandardVM2.2.

So, in case you are testing provisioning – create cluster and delete it. In case you want to use something permanent (install software, config it), please use another cluster(details above)

In case you have any questions, please ask then into bds-cga slack channel
*******

 # copy jdbc jars to sqoop’s home
dcli -f /opt/oracle/od4h/jlib/ojdbc8.jar -d $SQOOP_HOME/lib
dcli -f /opt/oracle/od4h/jlib/osdt_cert.jar -d $SQOOP_HOME/lib
dcli -f /opt/oracle/od4h/jlib/osdt_core.jar -d $SQOOP_HOME/lib
dcli -f /opt/oracle/od4h/jlib/oraclepki.jar -d $SQOOP_HOME/lib

 # after unzipping the ADW wallet … ensure that the wallet is owned by <user>:sqoop
export HADOOP_OPTS="- [Doracle.net.tns_admin=/tmp/wallet](http://Doracle.net.tns_admin=/tmp/wallet) - [Doracle.net.wallet_location=/tmp/wallet](http://Doracle.net.wallet_location=/tmp/wallet)" 

sqoop import -D mapreduce.map.java.opts='- [Doracle.net.tns_admin=](http://Doracle.net.tns_admin=). - [Doracle.net.wallet_location=](http://Doracle.net.wallet_location=).' -files /tmp/wallet/cwallet.sso,/tmp/wallet/ewallet.p12,/tmp/wallet/sqlnet.ora,/tmp/wallet/tnsnames.ora --m 1 --connect "jdbc:oracle:thin:@adwdemo_low" --username admin --password WelcomeCloudSQL1! --table WEATHER --columns "STATION, STATION_NAME" --target-dir '/user/oracle/weather'