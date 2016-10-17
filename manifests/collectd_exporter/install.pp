# Class prometheus::collectd_exporter::install
# Install prometheus collectd_exporter via different methods with parameters from init
# Currently only the install from url is implemented, when Prometheus will deliver packages for some Linux distros I will
# implement the package install method as well
# The package method needs specific yum or apt repo settings which are not made yet by the module
class prometheus::collectd_exporter::install
{

  case $::prometheus::collectd_exporter::install_method {
    'url': {
      include staging
      $staging_file = "collectd_exporter-${prometheus::collectd_exporter::version}.${prometheus::collectd_exporter::download_extension}"
      $binary = "${::staging::path}/collectd_exporter-${::prometheus::collectd_exporter::version}.${::prometheus::collectd_exporter::os}-${::prometheus::collectd_exporter::arch}/collectd_exporter"
      staging::file { $staging_file:
        source => $prometheus::collectd_exporter::real_download_url,
      } ->
      staging::extract { $staging_file:
        target  => $::staging::path,
        creates => $binary,
      } ->
      file {
        $binary:
          owner => 'root',
          group => 0, # 0 instead of root because OS X uses "wheel".
          mode  => '0555';
        "${::prometheus::collectd_exporter::bin_dir}/collectd_exporter":
          ensure => link,
          notify => $::prometheus::collectd_exporter::notify_service,
          target => $binary,
      }
    }
    'package': {
      package { $::prometheus::collectd_exporter::package_name:
        ensure => $::prometheus::collectd_exporter::package_ensure,
      }
      if $::prometheus::collectd_exporter::manage_user {
        User[$::prometheus::collectd_exporter::user] -> Package[$::prometheus::collectd_exporter::package_name]
      }
    }
    'none': {}
    default: {
      fail("The provided install method ${::prometheus::install_method} is invalid")
    }
  }
  if $::prometheus::collectd_exporter::manage_user {
    ensure_resource('user', [ $::prometheus::collectd_exporter::user ], {
      ensure => 'present',
      system => true,
      groups => $::prometheus::collectd_exporter::extra_groups,
    })

    if $::prometheus::collectd_exporter::manage_group {
      Group[$::prometheus::collectd_exporter::group] -> User[$::prometheus::collectd_exporter::user]
    }
  }
  if $::prometheus::collectd_exporter::manage_group {
    ensure_resource('group', [ $::prometheus::collectd_exporter::group ], {
      ensure => 'present',
      system => true,
    })
  }
}
