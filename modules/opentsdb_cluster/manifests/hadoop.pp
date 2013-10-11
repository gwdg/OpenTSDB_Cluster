class opentsdb_cluster::hadoop {
  include opentsdb_cluster::virtual_user

  package { "openjdk-6-jdk":
    ensure  => installed,
    require => Exec["extract_hadoop"],
  }
  
  file{"aaa":
    path  => "${opentsdb_cluster::hadoop_parent_dir}",
    ensure  => directory,
    recurse => false,
    owner   => "${opentsdb_cluster::myuser_name}",
    group   => "${opentsdb_cluster::mygroup_name}",
    require => User["gwdg"],
  }

  # #download hadoop
  exec { "download_hadoop":
    command => "wget ${opentsdb_cluster::hadoop_source_link}", #; tar xzf hadoop-${opentsdb_cluster::hadoop_version}.tar.gz",
    cwd     => "${opentsdb_cluster::hadoop_parent_dir}",
    path    => "/bin:/usr/bin",
    creates => "${opentsdb_cluster::hadoop_parent_dir}/hadoop-${opentsdb_cluster::hadoop_version}.tar.gz",#"${opentsdb_cluster::hadoop_working_dir}",
    
    require => [User["gwdg"], File["aaa"]],
  }
  exec{"extract_hadoop":
    command => "tar xzf hadoop-${opentsdb_cluster::hadoop_version}.tar.gz",
    cwd     => "${opentsdb_cluster::hadoop_parent_dir}",
    path    => $::path,
    creates => "${opentsdb_cluster::hadoop_working_dir}",
    require => Exec["download_hadoop"],
  }
#  exec{"update":
#    command => "apt-get update",
#    path => $::path,
#    tries => 3,
#    user => "${opentsdb_cluster::myuser_name}",
#  }

  # # re-own file
  file { "reown_hadoop":
    path    => "${opentsdb_cluster::hadoop_working_dir}",
    backup  => false,
    recurse => true,
    owner   => "${opentsdb_cluster::myuser_name}",
    group   => "${opentsdb_cluster::mygroup_name}",
    require => [Exec["extract_hadoop"], User["gwdg"], Package["openjdk-6-jdk"]],
  }
  # # add environment variable
  $var = template("opentsdb_cluster/hadoop_env_var.erb")

  exec { "add_env_var":
    command => "echo '${var}' >> /home/${opentsdb_cluster::myuser_name}/.bashrc",
    path    => $::path,
    unless  => "grep -q 'HADOOP' /home/${opentsdb_cluster::myuser_name}/.bashrc",
    require => File["reown_hadoop"],
  }

  # #create folder to store data
  file { ["/app", "/app/hadoop", "/app/hadoop/tmp"]:
    ensure  => directory,
    owner   => "${opentsdb_cluster::myuser_name}",
    group   => "${opentsdb_cluster::mygroup_name}",
    require => User["gwdg"],
    before  => File["reown_hadoop"],
    mode    => 750,
  }
  include opentsdb_cluster::hadoop::copy_file

}

class opentsdb_cluster::hadoop::copy_file {
  file { "core-site":
    path    => "${opentsdb_cluster::hadoop_working_dir}/conf/core-site.xml",
    content => template("opentsdb_cluster/hadoop/conf/core-site.xml.erb"),
    ensure  => present,
    owner   => "${opentsdb_cluster::myuser_name}",
    group   => "${opentsdb_cluster::mygroup_name}",
    require => File["reown_hadoop"],
  }

  file { "hadoop-env":
    path    => "${opentsdb_cluster::hadoop_working_dir}/conf/hadoop-env.sh",
    content => template("opentsdb_cluster/hadoop/conf/hadoop-env.sh.erb"),
    ensure  => present,
    owner   => "${opentsdb_cluster::myuser_name}",
    group   => "${opentsdb_cluster::mygroup_name}",
    require => File["reown_hadoop"],
  }

  file { "hdfs-site":
    path    => "${opentsdb_cluster::hadoop_working_dir}/conf/hdfs-site.xml",
    content => template("opentsdb_cluster/hadoop/conf/hdfs-site.xml.erb"),
    ensure  => present,
    owner   => "${opentsdb_cluster::myuser_name}",
    group   => "${opentsdb_cluster::mygroup_name}",
    require => File["reown_hadoop"],
  }

  file { "mapred-site":
    path    => "${opentsdb_cluster::hadoop_working_dir}/conf/mapred-site.xml",
    content => template("opentsdb_cluster/hadoop/conf/mapred-site.xml.erb"),
    ensure  => present,
    owner   => "${opentsdb_cluster::myuser_name}",
    group   => "${opentsdb_cluster::mygroup_name}",
    require => File["reown_hadoop"],
  }

  file { "masters":
    path    => "${opentsdb_cluster::hadoop_working_dir}/conf/masters",
    content => template("opentsdb_cluster/hadoop/conf/masters.erb"),
    ensure  => present,
    owner   => "${opentsdb_cluster::myuser_name}",
    group   => "${opentsdb_cluster::mygroup_name}",
    require => File["reown_hadoop"],
  }

  file { "slaves":
    path    => "${opentsdb_cluster::hadoop_working_dir}/conf/slaves",
    content => template("opentsdb_cluster/hadoop/conf/slaves.erb"),
    ensure  => present,
    owner   => "${opentsdb_cluster::myuser_name}",
    group   => "${opentsdb_cluster::mygroup_name}",
    require => File["reown_hadoop"],
  }

}

class opentsdb_cluster::hadoop::format {
  include opentsdb_cluster::virtual_user::ssh_conn
  include opentsdb_cluster::virtual_user::auth_file

  exec { "format_hadoop":
    command => "hadoop namenode -format",
    cwd     => "${opentsdb_cluster::hadoop_working_dir}/bin",
    path    => "${path}:${opentsdb_cluster::hadoop_working_dir}/bin",
    creates => "${opentsdb_cluster::hadoop_working_dir}/format_done",
    user    => $opentsdb_cluster::myuser_name,
    require => [
      File["reown_hadoop"],
      File["core-site"],
      File["hadoop-env"],
      File["hdfs-site"],
      File["mapred-site"],
      File["masters"],
      File["slaves"],
      File["id_rsa"],
      File["id_rsa.pub"],
      File["authorized_keys"]],
  }

  file { "format_done":
    path    => "${opentsdb_cluster::hadoop_working_dir}/format_done",
    ensure  => directory,
    require => Exec["format_hadoop"],
  }
}
 
class opentsdb_cluster::hadoop::service {
  include opentsdb_cluster::virtual_user::ssh_conn
  include opentsdb_cluster::virtual_user::auth_file

  file { "hadoop_service":
    ensure  => present,
    path    => "${opentsdb_cluster::service_path}/hadoop",
    content => template("opentsdb_cluster/hadoop/service/hadoop.erb"),
    owner   => "${opentsdb_cluster::myuser_name}",
    group   => "${opentsdb_cluster::mygroup_name}",
    mode    => 777,
    require => File["reown_hadoop"],
    notify  => Service["hadoop"],
  }

  service { "hadoop":
    ensure  => running,
    require => [Exec["format_hadoop"], File["hadoop_service"], File["id_rsa"], File["id_rsa.pub"], File["authorized_keys"]],
  }
   
}

