# Class prometheus::jmx_exporter::install
# Install prometheus node jmx_exporter via different methods with parameters from init
# Currently only the install from url is implemented, when Prometheus will deliver packages for some Linux distros I will
# implement the package install method as well
# The package method needs specific yum or apt repo settings which are not made yet by the module
class prometheus::jmx_exporter::install
{

  case $::prometheus::jmx_exporter::install_method {
    'url': {
      include ::staging
      $staging_file = "jmx_exporter-${prometheus::jmx_exporter::version}.${prometheus::jmx_exporter::download_extension}"
      $binary = "${::staging::path}/jmx_exporter-${::prometheus::jmx_exporter::version}.${::prometheus::jmx_exporter::os}-${::prometheus::jmx_exporter::arch}/jmx_exporter"
      staging::file { $staging_file:
        source => $prometheus::jmx_exporter::real_download_url,
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
        "${::prometheus::jmx_exporter::bin_dir}/jmx_exporter":
          ensure => link,
          notify => $::prometheus::jmx_exporter::notify_service,
          target => $binary,
      }
    }
    'package': {
      package { $::prometheus::jmx_exporter::package_name:
        ensure => $::prometheus::jmx_exporter::package_ensure,
      }
      if $::prometheus::jmx_exporter::manage_user {
        User[$::prometheus::jmx_exporter::user] -> Package[$::prometheus::jmx_exporter::package_name]
      }
    }
    'none': {}
    default: {
      fail("The provided install method ${::prometheus::install_method} is invalid")
    }
  }
  if $::prometheus::jmx_exporter::manage_user {
    ensure_resource('user', [ $::prometheus::jmx_exporter::user ], {
      ensure => 'present',
      system => true,
      groups => $::prometheus::jmx_exporter::extra_groups,
    })

    if $::prometheus::jmx_exporter::manage_group {
      Group[$::prometheus::jmx_exporter::group] -> User[$::prometheus::jmx_exporter::user]
    }
  }
  if $::prometheus::jmx_exporter::manage_group {
    ensure_resource('group', [ $::prometheus::jmx_exporter::group ], {
      ensure => 'present',
      system => true,
    })
  }
}
