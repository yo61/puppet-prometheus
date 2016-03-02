# == Class prometheus::node_exporter::service
#
# This class is meant to be called from prometheus::node_exporter
# It ensure the node_exporter service is running
#
class prometheus::node_exporter::run_service {

  $init_selector = $prometheus::node_exporter::init_style ? {
    'launchd' => 'io.node_exporter.daemon',
    default   => 'node_exporter',
  }

  if $prometheus::node_exporter::manage_service == true {
    service { 'node_exporter':
      ensure => $prometheus::node_exporter::service_ensure,
      name   => $init_selector,
      enable => $prometheus::node_exporter::service_enable,
    }
  }
}
