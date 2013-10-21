class opentsdb_cluster::mypuppetdb {
  if $::hostname == $opentsdb_cluster::puppet_hostname {
    ini_setting { "my_stoteconfigs":
      ensure            => present,
      path              => "/etc/puppet/puppet.conf",
      section           => "main",
      setting           => "storeconfigs",
      value             => "true",
      key_val_separator => "=",
    }

    ini_setting { "my_stoteconfig_backend":
      ensure            => present,
      path              => "/etc/puppet/puppet.conf",
      section           => "main",
      setting           => "storeconfigs_backend",
      value             => "puppetdb",
      key_val_separator => "=",
    }

    class { 'puppetdb':
      database => "${opentsdb_cluster::database_type}",
    }

    class { 'puppetdb::master::config':
      puppetdb_server => "${::hostname}",
      puppetdb_port   => 8081,
    }
  }
  
}