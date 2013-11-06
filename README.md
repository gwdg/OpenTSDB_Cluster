Installation of OpenTSDB with cluster of hbase machine.
==========
<h1> Preparation </h1>

1.) One master machine in which puppet master, puppetdb installed.
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

2.) A few slave machines connecting to master machine.

3.) A master machine should be able to connect to other slave machines passwordlessly.

<h1> Install OpenTSDB module </h1>

1.) In the master machine, get the OpenTSDB installation repo via https://github.com/gwdg/OpenTSDB_Cluster

2.) Copy its manifests and modules to /etc/puppet/

3.) In file /etc/puppet/manifests/site.pp, use could edit some configuration like this:



```puppet
node "master_machine" {

  class { 'opentsdb_cluster':
        install_hadoop     => true,        ## install hadoop for master machine
        install_hbase      => true,        ## install hbase for master machine
        install_opentsdb   => true,        ## install opentsdb
        install_tcollector => true,        ## tcollector
    	setup_user     => true, # # set up dedicated user name 'gwdg' in group 'goettingen'.
    	setup_puppetdb => true,
	database_type => "embedded", # # embedded for testing small environment, using 'postgreps' for production
  # ###Moreover, this master machine with user 'gwdg' coule be able to connect to every slave machines without password.
  #    	setup_lzo          => true,        ## enable lzo-compression, if you enable lzo-compression in master machine, you have to set it on every slave machines
  }
}
}
```

```puppet
node "slave_machine" {
  class { 'opentsdb_cluster':
       	install_hadoop     => true,       ## install hadoop for slave machine
        install_hbase      => true,      ## install hbase for slave machine
    #    install_opentsdb   => false,     ## opentsdb should not be installed in any slave machine
    #    install_tcollector => false,     ## tcollector should not be installed in any slave machine
    #    setup_lzo          => true,      ## if lzo-compression in master machine is enable, this compression have to be enable in
    #    every slave machine.
    setup_user => true, # # set up user name 'gwdg' in group 'goettingen', which allows master machine passwordlessly connecting.
  }
}
```

Moreover, according to your specific environment, you could find and change all parameters in /etc/puppet/module/opentsdb_cluster/manifests/init.pp
For example:

```puppet
class opentsdb_cluster (
  $puppet_hostname         = "masterdb",
  $slave_hostname          = "slavedb",			## depricated because of using puppetdb
  $slave_ip                = "192.168.33.65",		## depricated because of using puppetdb
  $puppet_ip               = "192.168.33.60", 
  $myuser_name             = "gwdg",
  $myuser_id               = "1010",
  $myuser_passwd           = '\$6\$aqzOtgCM\$OxgoMP4JoqMJ1U1F3MZPo2iBefDRnRCXSfgIM36E5cfMNcE7GcNtH1P/tTC2QY3sX3BxxJ7r/9ciScIVTa55l0',
  # #vagrant
  $mygroup_name            = "goettingen",
  $mygroup_id              = "1010",
  $hadoop_parent_dir       = "/usr/local",
  $hadoop_version          = "1.2.1",
  $hadoop_version_in_hbase = "1.0.4",
  $hadoop_source_link      = "http://archive.apache.org/dist/hadoop/core/hadoop-1.2.1/hadoop-1.2.1.tar.gz",
  $java_home               = "/usr/lib/jvm/java-1.6.0-openjdk-amd64",
  $service_path            = "/etc/init.d",
  $hbase_parent_dir        = "/usr/local",
  $hbase_version           = "0.94.12",
  $hbase_source_link       = "https://archive.apache.org/dist/hbase/stable/hbase-0.94.12.tar.gz",
  $opentsdb_parent_dir     = "/usr/local",
  $opentsdb_port           = 4242,
  $compression             = 'NONE',
  $os_structure            = 'Linux-amd64-64',
  $master_node             = false,
  $tcollector_parent_dir   = "/usr/local",
  $install_hadoop          = false,
  $install_hbase           = false,
  $install_opentsdb        = false,
  $install_tcollector      = false,
  $setup_user              = false,
  $setup_lzo               = false,
  $setup_puppetdb          = false, 
  $lzo_parent_dir          = "/usr/local",
  $database_type           = "embedded" )
```

