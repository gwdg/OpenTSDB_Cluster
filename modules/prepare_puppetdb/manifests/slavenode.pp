class prepare_puppetdb::slavenode{
  ini_setting { "puppet.conf":
    path              => "/etc/puppet/puppet.conf",
    section           => "agent",
    setting           => "server",
    value             => "masterdb",
    key_val_separator => "=",
  }
}