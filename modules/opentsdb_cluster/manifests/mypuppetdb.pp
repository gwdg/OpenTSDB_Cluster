class opentsdb_cluster::mypuppetdb {
  if $::hostname == $opentsdb_cluster::puppet_hostname {
    file { "/etc/puppet/autosign.conf":
      ensure  => present,
      content => '*',
    }

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
    Host <<| tag == "slave_host" |>>
  }
  ##########
  @@host{"Host${::hostname}":
    ip    => $::is_virtual?{
      /true/    => $::ipaddress_eth1,
      default    => $::ipaddress_eth0, 
    },
    name      => $::hostname,
    host_aliases  => [$::fqdn],
    tag     => "slave_host",
  }

}