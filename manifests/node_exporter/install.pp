# Class prometheus::node_exporter::install
# Install prometheus node node_exporter via different methods with parameters from init
# Currently only the install from url is implemented, when Prometheus will deliver packages for some Linux distros I will
# implement the package install method as well
# The package method needs specific yum or apt repo settings which are not made yet by the module
class prometheus::node_exporter::install
{
  case $::prometheus::node_exporter::install_method {
    'url': {
      include staging
      $staging_file = "node_exporter-${prometheus::node_exporter::version}.${prometheus::node_exporter::download_extension}"
      $binary = "${::staging::path}/prometheus-${prometheus::version}.${prometheus::os}-${prometheus::arch}/prometheus"
      staging::file { "${staging_file}":
        source => $prometheus::node_exporter::real_download_url,
      } ->
      file { "${::staging::path}/node_exporter-${prometheus::node_exporter::version}":
        ensure => directory,
      } ->
      staging::extract { "${staging_file}":
        target  => "${::staging::path}",
        creates => "${::staging::path}/prometheus-${prometheus::version}.${prometheus::os}-${prometheus::arch}/prometheus",
      } ->
      file {
        "${::staging::path}/prometheus-${prometheus::version}.${prometheus::os}-${prometheus::arch}/prometheus":
          owner => 'root',
          group => 0, # 0 instead of root because OS X uses "wheel".
          mode  => '0555';
        "${::prometheus::bin_dir}/prometheus":
          ensure => link,
          notify => $::prometheus::notify_service,
          target => "${::staging::path}/prometheus-${prometheus::version}.${prometheus::os}-${prometheus::arch}/prometheus";
      }
     }
     'package': {
      package { $::prometheus::package_name:
        ensure => $::prometheus::package_ensure,
      }
      if $::prometheus::manage_user {
        User[$::prometheus::user] -> Package[$::prometheus::package_name]
      }
    }
     'none': {}
    default: {
      fail("The provided install method ${::prometheus::install_method} is invalid")
    }
  }
   if $::prometheus::manage_user {
    user { $::prometheus::user:
      ensure => 'present',
      system => true,
      groups => $::prometheus::extra_groups,
    }

    if $::prometheus::manage_group {
      Group[$::prometheus::group] -> User[$::prometheus::user]
    }
  }
  if $::prometheus::manage_group {
    group { $::prometheus::group:
      ensure => 'present',
      system => true,
    }
  }
}
