Installation of OpenTSDB (opentsdb.net) with cluster of hbase machine.
==========
<h1> Preparation </h1>
i.) One master machine in which puppet master, puppetdb installed.
	Find and edit configuration file /etc/puppet/puppet.conf
	[main]
	.
	.
	.
	storeconfigs = true
	storeconfigs_backend = puppetdb
	
	Find and edit dns (/etc/hosts)
	127.0.0.1	localhost	<hostname> <all aliases>
	This is very important configuration. Without this, hadoop and hbase could not work properly. 

ii.) A few slave machines connecting to master machine.
