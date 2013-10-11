#import "puppetdb/*"
/*
class opentsdb_cluster::puppet_database {
  # # prepare
  if $opentsdb_cluster::puppet_hostname == $::hostname {
    file { "/etc/puppet/autosign.conf":
      ensure  => present,
      content => '*',
    }

    ini_setting { "dns_alt_names":
      path              => "/etc/puppet/puppet.conf",
      section           => "master",
      setting           => "dns_alt_names",
      value             => $::hostname,
      key_val_separator => "=",
    }

    ini_setting { "storeconfigs":
      path              => "/etc/puppet/puppet.conf",
      section           => "main",
      setting           => "storeconfigs",
      value             => "true",
      key_val_separator => "=",
    }
    host{"master":
      name    => $::hostname,
      ip      => $::ipaddress_eth1,
    }
    host{"slave":
      name    => $opentsdb_cluster::slave_hostname,
      ip      => $opentsdb_cluster::slave_ip,
    }

    class { 'puppetdb':
      database => 'embedded',
    }

    class { 'puppetdb::master::config':
      puppetdb_server => $::hostname,
      puppetdb_port   => 8081,
      
    }
     
    
  } else {
    ini_setting { "puppet_server":
      path              => "/etc/puppet/puppet.conf",
      section           => "agent",
      setting           => "server",
      value             => $opentsdb_cluster::puppet_hostname,
      key_val_separator => "=",
    }
  }
  include opentsdb_cluster::puppet_database::common

}

class opentsdb_cluster::puppet_database::common {
  ini_setting { "puppet_defalt":
    path              => "/etc/default/puppet",
    section           => "",
    setting           => "START",
    value             => "yes",
    key_val_separator => "=",
  }

#  @@host { "${hostname}":
#    name   => $::hostname,
#    ip     => $::ipaddress_eth1,
#    ensure => present,
#    tag    => "hostname",
#  }
}

*/