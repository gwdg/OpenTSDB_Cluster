class opentsdb_cluster::tcollector{
  include opentsdb_cluster::opentsdb
  ## download
  exec{"download_tcollector":
    command   => "git clone https://github.com/dtklinh/tcollector",
    cwd       => $opentsdb_cluster::tcollector_parent_dir,
    user      => $opentsdb_cluster::myuser_name,
    creates   => $opentsdb_cluster::tcollector_working_dir,
    require   => User["gwdg"],
    path      => $::path,
  }
  file{"reown_tcollector":
    path      => $opentsdb_cluster::tcollector_working_dir,
    backup    => false,
    recurse   => true,
    owner   => $opentsdb_cluster::myuser_name,
    group   => $opentsdb_cluster::mygroup_name,
    require => Exec["download_tcollector"],
  }
  file{"/var/log/tcollector.log":
    ensure  => present,
    owner   => $opentsdb_cluster::myuser_name,
    group   => $opentsdb_cluster::mygroup_name,
    require => File["reown_tcollector"],
  }
  file{"startstop":
    path    => "${opentsdb_cluster::tcollector_working_dir}/startstop",
    ensure  => present,
    content => template("opentsdb_cluster/tcollector/conf/startstop.erb"),
    owner   => $opentsdb_cluster::myuser_name,
    group   => $opentsdb_cluster::mygroup_name,
    mode    => 777,
    require => File["reown_tcollector"],
    notify  => Service["tcollector"],
  }
  ## service
  file{"tcollector_service":
    path    => "${opentsdb_cluster::service_path}/tcollector",
    content => template("opentsdb_cluster/tcollector/service/tcollector.erb"),
    ensure  => present,
    mode    => 777,
    owner   => $opentsdb_cluster::myuser_name,
    group   => $opentsdb_cluster::mygroup_name,
    notify  => Service["tcollector"],
    require => File["startstop"],
  }
  
  service{"tcollector":
    ensure  => running,
    require => [File["tcollector_service"], Service["opentsdb"], File["/var/log/tcollector.log"]],
  }
}


