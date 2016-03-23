# == Class prometheus::alert_manager::service
#
# This class is meant to be called from prometheus::alert_manager
# It ensure the alert_manager service is running
#
class prometheus::alert_manager::run_service {

  $init_selector = $prometheus::alert_manager::init_style ? {
    'launchd' => 'io.alert_manager.daemon',
    default   => 'alert_manager',
  }

  if $prometheus::alert_manager::manage_service == true {
    service { 'alert_manager':
      ensure => $prometheus::alert_manager::service_ensure,
      name   => $init_selector,
      enable => $prometheus::alert_manager::service_enable,
    }
  }
}
