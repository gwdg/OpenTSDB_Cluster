class opentsdb_cluster (
  $puppet_hostname         = "masterdb",
  $slave_hostname          = "slavedb",
  $slave_ip                = "192.168.33.65",
  $puppet_ip               = "192.168.33.60", 
  $myuser_name             = "gwdg",
  $myuser_id               = "1010",
  $myuser_passwd           = '\$6\$aqzOtgCM\$OxgoMP4JoqMJ1U1F3MZPo2iBefDRnRCXSfgIM36E5cfMNcE7GcNtH1P/tTC2QY3sX3BxxJ7r/9ciScIVTa55l0',
  # #vagrant
  $mygroup_name            = "goettingen",
  $mygroup_id              = "1010",
  $hadoop_parent_dir       = "/usr/local",
  $hadoop_version          = "1.2.1",
  $hadoop_version_in_hbase = "1.0.4",
  $hadoop_source_link      = "http://archive.apache.org/dist/hadoop/core/stable/hadoop-1.2.1.tar.gz",
  $java_home               = "/usr/lib/jvm/java-1.6.0-openjdk-amd64",
  $service_path            = "/etc/init.d",
  $hbase_parent_dir        = "/usr/local",
  $hbase_version           = "0.94.12",
  $hbase_source_link       = "https://archive.apache.org/dist/hbase/stable/hbase-0.94.12.tar.gz",
  $opentsdb_parent_dir     = "/usr/local",
  $opentsdb_port           = 4242,
  $compression             = 'NONE',
  $os_structure            = 'Linux-amd64-64',
  $master_node             = false,
  $tcollector_parent_dir   = "/usr/local",
  $install_hadoop          = false,
  $install_hbase           = false,
  $install_opentsdb        = false,
  $install_tcollector      = false,
  $setup_user              = false,
  $setup_lzo               = false,
  $lzo_parent_dir          = "/usr/local") {
  $hadoop_working_dir = "${hadoop_parent_dir}/hadoop-${hadoop_version}"
  $hbase_working_dir = "${hbase_parent_dir}/hbase-${hbase_version}"
  $opentsdb_working_dir = "${opentsdb_parent_dir}/opentsdb"
  $tcollector_working_dir = "${tcollector_parent_dir}/tcollector"
  $lzo_working_dir = "${lzo_parent_dir}/lzo"

  # ############################# init ###################################
  #  include opentsdb_cluster::puppet_database
  #  Host <<| tag == "hostname" |>>

  # ################################---install LZO---############################################
  if $setup_lzo == true {
        include opentsdb_cluster::compression
    #include opentsdb_cluster::lzo
  }

  ###########################################################################
  # #######################---Prepare Machines---########################
  if $setup_user == true {
    include opentsdb_cluster::virtual_user
    User <| title == "gwdg" |>
    Group <| title == "goettingen" |>
    include opentsdb_cluster::virtual_user::add_role

    if $::hostname == "${puppet_hostname}" {
      include opentsdb_cluster::virtual_user::ssh_conn
    }
    include opentsdb_cluster::virtual_user::auth_file

  }

  #######################################################################

  # #########################---Install Hadoop---#########################
  if $install_hadoop == true {
    include opentsdb_cluster::hadoop

    if $::hostname == $puppet_hostname {
      include opentsdb_cluster::hadoop::format
      include opentsdb_cluster::hadoop::service
    }
  }

  #######################################################################

  # #########################---Install Hbase---##########################
  if $install_hbase == true {
    include opentsdb_cluster::hbase

    if $::hostname == $puppet_hostname {
      include opentsdb_cluster::hbase::service
    }
  }

  #######################################################################
  # ##########################--- Install LZO ---##########################
  #  if $compression == 'LZO'{
  #    include opentsdb_cluster::lzo
  #  }
  ########################################################################

  # ########################---Install Opentsdb---########################
  if $install_opentsdb == true {
    include opentsdb_cluster::opentsdb
  }

  #######################################################################

  # ########################---Install Tcollector---########################
  if $install_tcollector == true {
    include opentsdb_cluster::tcollector
  }
  #######################################################################
  /*
   * include opentsdb_cluster::hadoop
   * include opentsdb_cluster::hbase
   * if $::hostname == $puppet_hostname{
   *  include opentsdb_cluster::hadoop::format
   *  include opentsdb_cluster::hadoop::service
   *  include opentsdb_cluster::hbase::service
   *  include opentsdb_cluster::opentsdb
   *  include opentsdb_cluster::tcollector
   *}
   */
}