class prepare_puppetdb ($a = true) {
#  @@file { "/etc/puppet/${hostname}.txt":
#    ensure  => present,
#    content => "${hostname}\n",
#    tag     => "linh",
#  }

  file { "/etc/puppet/hostname.txt": ensure => present, }

  @@file_line{"test${hostname}":
    path    => "/etc/puppet/hostname.txt",
    ensure  => present,
    line    => $::hostname,
    require => File["/etc/puppet/hostname.txt"],
    tag     => "gwdg",
  }
  if $::hostname == "masterdb"{
    File_line <<| tag == "gwdg" |>>
  }
}