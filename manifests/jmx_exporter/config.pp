# Class prometheus::jmx_exporter::config
# Configuration class for prometheus node jmx exporter
class prometheus::jmx_exporter::config(
  $purge = true,
) {

  if $prometheus::jmx_exporter::init_style {

    case $prometheus::jmx_exporter::init_style {
      'upstart' : {
        file { '/etc/init/jmx_exporter.conf':
          mode    => '0444',
          owner   => 'root',
          group   => 'root',
          content => template('prometheus/jmx_exporter.upstart.erb'),
        }
        file { '/etc/init.d/jmx_exporter':
          ensure => link,
          target => '/lib/init/upstart-job',
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
        }
      }
      'systemd' : {
        file { '/lib/systemd/system/jmx_exporter.service':
          mode    => '0644',
          owner   => 'root',
          group   => 'root',
          content => template('prometheus/jmx_exporter.systemd.erb'),
        }~>
        exec { 'jmx_exporter-systemd-reload':
          command     => 'systemctl daemon-reload',
          path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
          refreshonly => true,
        }
      }
      'sysv' : {
        file { '/etc/init.d/jmx_exporter':
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('prometheus/jmx_exporter.sysv.erb'),
        }
      }
      'debian' : {
        file { '/etc/init.d/jmx_exporter':
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('prometheus/jmx_exporter.debian.erb'),
        }
      }
      'sles' : {
        file { '/etc/init.d/jmx_exporter':
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('prometheus/jmx_exporter.sles.erb'),
        }
      }
      'launchd' : {
        file { '/Library/LaunchDaemons/io.jmx_exporter.daemon.plist':
          mode    => '0644',
          owner   => 'root',
          group   => 'wheel',
          content => template('prometheus/jmx_exporter.launchd.erb'),
        }
      }
      default : {
        fail("I don't know how to create an init script for style ${prometheus::jmx_exporter::init_style}")
      }
    }
  }

}
