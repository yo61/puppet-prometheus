# == Class prometheus::collectd_exporter::service
#
# This class is meant to be called from prometheus::collectd_exporter
# It ensure the collectd_exporter service is running
#
class prometheus::collectd_exporter::run_service {

  $init_selector = $prometheus::collectd_exporter::init_style ? {
    'launchd' => 'io.collectd_exporter.daemon',
    default   => 'collectd_exporter',
  }

  if $prometheus::collectd_exporter::manage_service == true {
    service { 'collectd_exporter':
      ensure => $prometheus::collectd_exporter::service_ensure,
      name   => $init_selector,
      enable => $prometheus::collectd_exporter::service_enable,
    }
  }
}
