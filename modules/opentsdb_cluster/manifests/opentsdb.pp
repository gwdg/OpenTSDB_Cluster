class opentsdb_cluster::opentsdb{
  include opentsdb_cluster::hbase
  ## download package
  package{["dh-autoreconf","gnuplot"]:
    ensure  => installed,
  }
  exec{"download_opentsdb":
#    command => "git clone git://github.com/stumbleupon/opentsdb.git",
    command => "git clone git://github.com/OpenTSDB/opentsdb.git",
    cwd     => $opentsdb_cluster::opentsdb_parent_dir,
    creates => "${opentsdb_cluster::opentsdb_parent_dir}/opentsdb",
    user    => $opentsdb_cluster::myuser_name,
    require => [Package["dh-autoreconf"],Package["gnuplot"], User["gwdg"]],
    path      => $::path,
  }
  ## reown
  file{"reown_opentsdb":
    path  => "${opentsdb_cluster::opentsdb_working_dir}",
    backup => false,
    recurse => true,
    owner   => "${opentsdb_cluster::myuser_name}",
    group   => "${opentsdb_cluster::mygroup_name}",
    require => Exec["download_opentsdb"],
#    require => Exec["build_opentsdb"],
  }
  ## build opentsdb
  exec{"build_opentsdb":
    command   => "build.sh",
    cwd       => "${opentsdb_cluster::opentsdb_working_dir}",
    creates   => "${opentsdb_cluster::opentsdb_working_dir}/build/staticroot",
    user      => $opentsdb_cluster::myuser_name,
   # user      => root,
    require   => [File["reown_opentsdb"],Service["hbase"]],
#    require   => [Exec["download_opentsdb"],Service["hbase"]],
    path      => "${path}:${opentsdb_cluster::opentsdb_working_dir}",
    timeout   => 0,
  }
  ## create table
  exec{"create_table":
    command   => "env COMPRESSION=${opentsdb_cluster::compression} HBASE_HOME=${opentsdb_cluster::hbase_working_dir} ./src/create_table.sh",
    cwd       => $opentsdb_cluster::opentsdb_working_dir,
    user      => $opentsdb_cluster::myuser_name,
    creates   => "${opentsdb_cluster::opentsdb_working_dir}/create_table.txt",
    require   => Exec["build_opentsdb"],
    path      => $::path,
    timeout   => 0,
  }
  file{"${opentsdb_cluster::opentsdb_working_dir}/create_table.txt":
    ensure    => file,
    require    => Exec["create_table"],
  }
  ## run opentsdb service
  file{"opentsdb_service":
    path    => "${opentsdb_cluster::service_path}/opentsdb",
    content => template("opentsdb_cluster/opentsdb/service/opentsdb.erb"),
    ensure  => present,
    mode    => 777,
    require => File["reown_opentsdb"],
  }
  file{"/tmp/tsd":
    ensure    => directory,
    owner   => "${opentsdb_cluster::myuser_name}",
    group   => "${opentsdb_cluster::mygroup_name}",
  }
  service{"opentsdb":
    ensure  => running,
    require => [File["opentsdb_service"], Service["hbase"], File["/tmp/tsd"]],
    subscribe => File["opentsdb_service"],
  }
}


