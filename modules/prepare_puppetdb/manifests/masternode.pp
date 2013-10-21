class prepare_puppetdb::masternode{
  file { "/etc/puppet/autosign.conf":
    ensure  => present,
    content => '*',
  }
  ini_setting { "puppet.conf":
    path              => "/etc/puppet/puppet.conf",
    section           => "master",
    setting           => "dns_alt_names",
    value             => "${::hostname}",           #"masterdb",
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
  ini_setting{"stoteconfig_backend_new":
    ensure  => present,
    path    => "/etc/puppet/puppet.conf",
    section => "main",
    setting => "storeconfigs_backend",
    value   => "puppetdb",
    key_val_separator => "=",
  }
  class { 'puppetdb':
    database => "embedded",
  }

  class { 'puppetdb::master::config':
    puppetdb_server => "${::hostname}",
    puppetdb_port   => 8081,
  }
}