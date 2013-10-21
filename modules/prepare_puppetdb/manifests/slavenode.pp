class prepare_puppetdb::slavenode{
  ini_setting { "puppet.conf":
    path              => "/etc/puppet/puppet.conf",
    section           => "agent",
    setting           => "server",
    value             => "${opentsdb_cluster::puppet_hostname}",
    key_val_separator => "=",
  }
}