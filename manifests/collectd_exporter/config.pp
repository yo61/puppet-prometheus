# Class prometheus::collectd_exporter::config
# Configuration class for prometheus node exporter
class prometheus::collectd_exporter::config(
  $purge = true,
) {

  if $prometheus::collectd_exporter::init_style {

    case $prometheus::collectd_exporter::init_style {
      'upstart' : {
        file { '/etc/init/collectd_exporter.conf':
          mode    => '0444',
          owner   => 'root',
          group   => 'root',
          content => template('prometheus/collectd_exporter.upstart.erb'),
        }
        file { '/etc/init.d/collectd_exporter':
          ensure => link,
          target => '/lib/init/upstart-job',
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
        }
      }
      'systemd' : {
        file { '/lib/systemd/system/collectd_exporter.service':
          mode    => '0644',
          owner   => 'root',
          group   => 'root',
          content => template('prometheus/collectd_exporter.systemd.erb'),
        }~>
        exec { 'collectd_exporter-systemd-reload':
          command     => 'systemctl daemon-reload',
          path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
          refreshonly => true,
        }
      }
      'sysv' : {
        file { '/etc/init.d/collectd_exporter':
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('prometheus/collectd_exporter.sysv.erb'),
        }
      }
      'debian' : {
        file { '/etc/init.d/collectd_exporter':
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('prometheus/collectd_exporter.debian.erb'),
        }
      }
      'sles' : {
        file { '/etc/init.d/collectd_exporter':
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('prometheus/collectd_exporter.sles.erb'),
        }
      }
      'launchd' : {
        file { '/Library/LaunchDaemons/io.collectd_exporter.daemon.plist':
          mode    => '0644',
          owner   => 'root',
          group   => 'wheel',
          content => template('prometheus/collectd_exporter.launchd.erb'),
        }
      }
      default : {
        fail("I don't know how to create an init script for style ${prometheus::collectd_exporter::init_style}")
      }
    }
  }

}
