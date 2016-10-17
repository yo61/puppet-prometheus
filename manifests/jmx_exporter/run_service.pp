# == Class prometheus::jmx_exporter::service
#
# This class is meant to be called from prometheus::jmx_exporter
# It ensure the jmx_exporter service is running
#
class prometheus::node_exporter::run_service {

  $init_selector = $prometheus::jmx_exporter::init_style ? {
    'launchd' => 'io.jmx_exporter.daemon',
    default   => 'jmx_exporter',
  }

  if $prometheus::jmx_exporter::manage_service == true {
    service { 'jmx_exporter':
      ensure => $prometheus::jmx_exporter::service_ensure,
      name   => $init_selector,
      enable => $prometheus::jmx_exporter::service_enable,
    }
  }
}
