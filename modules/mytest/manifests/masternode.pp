class mytest::masternode{
  file { "/etc/puppet/autosign.conf":
    ensure  => present,
    content => '*',
  }
  ini_setting { "puppet.conf":
    path              => "/etc/puppet/puppet.conf",
    section           => "master",
    setting           => "dns_alt_names",
    value             => "masterdb",
    key_val_separator => "=",
  }
  ini_setting{"stoteconfig_new":
    ensure  => present,
    path    => "/etc/puppet/puppet.conf",
    section => "main",
    setting => "storeconfigs",
    value   => "true",
    key_val_separator => "=",
  }
  class { 'puppetdb':
    database => 'embedded',
  }

  class { 'puppetdb::master::config':
    puppetdb_server => 'masterdb',
    puppetdb_port   => 8081,
  }
}