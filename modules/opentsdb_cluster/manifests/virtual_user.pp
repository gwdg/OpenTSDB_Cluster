class opentsdb_cluster::virtual_user {
  @user { "gwdg":
    name       => $opentsdb_cluster::myuser_name,
    ensure     => present,
    uid        => $opentsdb_cluster::myuser_id,
    gid        => $opentsdb_cluster::mygroup_id,
    # password          => '',#$opentsdb_cluster::myuser_passwd,
    home       => "/home/${opentsdb_cluster::myuser_name}",
    shell      => "/bin/bash",
    managehome => true,
    require    => Group["goettingen"],
  }

  @group { "goettingen":
    name   => $opentsdb_cluster::mygroup_name,
    ensure => present,
    gid    => $opentsdb_cluster::mygroup_id,
  }

#  host { "their_own":
#    name         => $::hostname,
#    host_aliases => [$::fqdn],
#    ip           => $::ipaddress_eth1,
#    ensure       => present,
#  }

  host { "their_own2":
    name   => $::hostname,
    host_aliases => [$::fqdn, "localhost"],
    ip     => '127.0.0.1',
    ensure => present,
  }
  
  file_line{"host":
    path    => "/etc/hosts",
    line    => "${::ipaddress_eth1}   ${::hostname}",
    ensure  => present,
  }


  if $::hostname == $opentsdb_cluster::puppet_hostname {
    host { "other_slave":
      name         => $opentsdb_cluster::slave_hostname,
      host_aliases => ["${opentsdb_cluster::slave_hostname}.${::domain}"],
      ip           => $opentsdb_cluster::slave_ip,
      ensure       => present,
    }
  } else {
    host { "master":
      name         => $opentsdb_cluster::puppet_hostname,
      host_aliases => ["${opentsdb_cluster::puppet_hostname}.${::domain}"],
      ip           => $opentsdb_cluster::puppet_ip,
      ensure       => present,
    }
  }

}

class opentsdb_cluster::virtual_user::add_role {
  exec { "SetPasswd":
    #    command     => "usermod -p ${opentsdb_cluster::myuser_passwd} ${opentsdb_cluster::myuser_name}; adduser
    #    ${opentsdb_cluster::myuser_name} sudo",
    command => "usermod -p ${opentsdb_cluster::myuser_passwd} ${opentsdb_cluster::myuser_name}; usermod -a -G sudo ${opentsdb_cluster::myuser_name}",
    # path        => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/opt/vagrant_ruby/bin",
    path    => $::path,
    creates => "/home/tmp_dir",
    require => [User["gwdg"]],
  #    refreshonly => true,
  }

  file { "/home/tmp_dir":
    ensure  => directory,
    require => Exec["SetPasswd"],
  }
  #  file{"/etc/sudoers":
  #    ensure    => present,
  #    content   => template("opentsdb_cluster/sudoers.erb"),
  #    mode      => 0440,
  #    owner      => root,
  #    group     => root,
  #  }
}

class opentsdb_cluster::virtual_user::ssh_conn {
  #  host{"slave":
  #    name            => $opentsdb_cluster::slave_hostname,
  #    ensure          => present,
  #    ip              => "${opentsdb_cluster::slave_ip}",
  #  }
  sshkey { "tsdb":
    type   => rsa,
    ensure => present,
    key    => template("opentsdb_cluster/id_rsa.pub.erb"),
  }

  file { "id_rsa":
    path    => "/home/${opentsdb_cluster::myuser_name}/.ssh/id_rsa",
    content => template("opentsdb_cluster/id_rsa.erb"),
    require => [File["/home/${opentsdb_cluster::myuser_name}/.ssh"], User["gwdg"]],
    owner   => "${opentsdb_cluster::myuser_name}",
    group   => "${opentsdb_cluster::mygroup_name}",
    mode    => 600,
  }

  file { "id_rsa.pub":
    path    => "/home/${opentsdb_cluster::myuser_name}/.ssh/id_rsa.pub",
    content => template("opentsdb_cluster/authorized_keys.erb"),
    require => [File["/home/${opentsdb_cluster::myuser_name}/.ssh"], User["gwdg"]],
    owner   => "${opentsdb_cluster::myuser_name}",
    group   => "${opentsdb_cluster::mygroup_name}",
    mode    => 600,
  }

  ssh_authorized_key { "${opentsdb_cluster::myuser_name}@${opentsdb_cluster::puppet_hostname}":
    ensure  => present,
    type    => rsa,
    key     => template("opentsdb_cluster/id_rsa.pub.erb"),
    user    => "${opentsdb_cluster::myuser_name}",
    target  => "/home/${opentsdb_cluster::myuser_name}/.ssh/authorized_keys",
    require => User["gwdg"],
  }
}

class opentsdb_cluster::virtual_user::auth_file {
  file { "/home/${opentsdb_cluster::myuser_name}/.ssh":
    ensure  => directory,
    require => User["gwdg"],
    owner   => "${opentsdb_cluster::myuser_name}",
    group   => "${opentsdb_cluster::mygroup_name}",
  #  mode            => 600,
  }

  file { "authorized_keys":
    path    => "/home/${opentsdb_cluster::myuser_name}/.ssh/authorized_keys",
    content => template("opentsdb_cluster/authorized_keys.erb"),
    require => [File["/home/${opentsdb_cluster::myuser_name}/.ssh"], User["gwdg"]],
    owner   => "${opentsdb_cluster::myuser_name}",
    group   => "${opentsdb_cluster::mygroup_name}",
    mode    => 600,
  }
}

