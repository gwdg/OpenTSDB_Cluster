class prepare_puppetdb::common{
  ini_setting { "puppet_default":
    path              => "/etc/default/puppet",
    section           => "",
    setting           => 'START',
    value             => 'yes',
    key_val_separator => '=',
  }
  host { "masterdb":
    name         => "masterdb",
#    host_aliases => ["masterdb.top.gwdg.de", "puppet"],
    ip           => '192.168.33.60',
    ensure       => present,
  }

  host { "slavedb":
    name         => "slavedb",
#    host_aliases => ["slavedb.top.gwdg.de", "agent"],
    ip           => '192.168.33.65',
    ensure       => present,
  }
}