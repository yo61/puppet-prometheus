# Class prometheus::params
# Include default parameters for prometheus class
class prometheus::params {
  $user = 'prometheus'
  $group = 'prometheus'
  $bin_dir = '/usr/local/bin'
  $config_dir = '/etc/prometheus'
  $localstorage = '/var/lib/prometheus'
  $install_method = 'url'
  $package_ensure = 'latest'
  $package_name = 'prometheus'
  $download_url_base = 'https://github.com/prometheus/prometheus/releases'
  $version = '0.16.2'
  $download_extension = 'tar.gz'
  $node_exporter_download_url_base = 'https://github.com/prometheus/node_exporter/releases'
  $node_exporter_version = '0.11.0'
  $node_exporter_download_extension = 'tar.gz'
  $node_exporter_collectors = ['diskstats','filesystem','loadavg','meminfo','netdev','stat,time']
  $node_exporter_package_ensure = 'latest'
  $node_exporter_package_name = 'node_exporter'
  $alertmanager_url_base = 'https://github.com/prometheus/alertmanager/releases'
  $alertmanager_configpath = '/etc/prometheus/alertmanager.yaml'
  $alertmanager_storagepath='/var/lib/alertmanager'
  $alertmanager_version = '0.1.0'
  $alertmanager_download_extension = 'tar.gz'
  $config_mode = '0660'
  $global_config = { 'scrape_interval'=> '15s', 'evaluation_interval'=> '15s', 'external_labels'=> { 'monitor'=>'master'}}
  $rule_files = [ "${config_dir}/alert.rules" ]
  $scrape_configs = [ { 'job_name'=> 'prometheus', 'scrape_interval'=> '10s', 'scrape_timeout'=> '10s', 'target_groups'=> [ { 'targets'=> [ 'localhost:9090' ], 'labels'=> { 'alias'=> 'Prometheus'} } ] } ]
  case $::architecture {
    'x86_64', 'amd64': { $arch = 'amd64' }
    'i386':            { $arch = '386'   }
    default:           {
      fail("Unsupported kernel architecture: ${::architecture}")
    }
  }

  $os = downcase($::kernel)

  if $::operatingsystem == 'Ubuntu' {
    if versioncmp($::operatingsystemrelease, '8.04') < 1 {
      $init_style = 'debian'
    } elsif versioncmp($::operatingsystemrelease, '15.04') < 0 {
      $init_style = 'upstart'
    } else {
      $init_style = 'systemd'
    }
  } elsif $::operatingsystem =~ /Scientific|CentOS|RedHat|OracleLinux/ {
    if versioncmp($::operatingsystemrelease, '7.0') < 0 {
      $init_style = 'sysv'
    } else {
      $init_style  = 'systemd'
    }
  } elsif $::operatingsystem == 'Fedora' {
    if versioncmp($::operatingsystemrelease, '12') < 0 {
      $init_style = 'sysv'
    } else {
      $init_style = 'systemd'
    }
  } elsif $::operatingsystem == 'Debian' {
    if versioncmp($::operatingsystemrelease, '8.0') < 0 {
      $init_style = 'debian'
    } else {
      $init_style = 'systemd'
    }
  } elsif $::operatingsystem == 'Archlinux' {
    $init_style = 'systemd'
  } elsif $::operatingsystem == 'OpenSuSE' {
    $init_style = 'systemd'
  } elsif $::operatingsystem =~ /SLE[SD]/ {
    if versioncmp($::operatingsystemrelease, '12.0') < 0 {
      $init_style = 'sles'
    } else {
      $init_style = 'systemd'
    }
  } elsif $::operatingsystem == 'Darwin' {
    $init_style = 'launchd'
  } elsif $::operatingsystem == 'Amazon' {
    $init_style = 'sysv'
  } else {
    $init_style = undef
  }
  if $init_style == undef {
    fail('Unsupported OS')
  }
}
