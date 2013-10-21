class puppetdb::server::extra {

      # Restart the PuppetDB service if settings change
      Class[puppetdb::server::extra] ~> Class[puppetdb::server]
      
      # Get PuppetDB confdir
      include puppetdb::params
      $confdir = $puppetdb::params::confdir

      # Set resource defaults assuming we're only doing [database] settings
      Ini_setting {
        path => "${confdir}/database.ini",
        ensure => present,
        section => 'database',
        require => Class['puppetdb::server::validate_db'],
      }

 #     ini_setting {'puppetdb_node_ttl':
 #       setting => 'node_ttl',
 #       value => '5d',
 #     }

 #     ini_setting {'puppetdb_report_ttl':
 #       setting => 'report_ttl',
 #       value => '30d',
 #     }

    }