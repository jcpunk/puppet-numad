# @summary Manage numad service and config
#
# This class will manage the numad service and associated config.
#
# @example
#   include numad
class numad (
  Boolean $package_manage = true,
  String $package_ensure  = 'installed',
  String $package_name    = 'numad',
  String $service_name    = 'numad.service',
  Stdlib::Ensure::Service $service_ensure = 'running',
  Boolean $service_enable = true,
  Stdlib::Absolutepath $numad_binary = '/usr/bin/numad',
  Optional[Array] $numad_arguments   = undef
) {

  if $package_manage {
    package { $package_name:
      ensure => $package_ensure,
      notify => Systemd::Unit_file[$service_name],
    }
  }

  if $service_ensure == 'running' {
    $unitfile_active = true
  } else {
    $unitfile_active = false
  }

  systemd::unit_file { $service_name:
    path   => '/usr/lib/systemd/system',
    enable => $service_enable,
    active => $unitfile_active,
  }

  if ! $numad_arguments.empty() {

    $dropin_params = {
      'numad_binary'    => $numad_binary,
      'numad_arguments' => $numad_arguments,
    }

    systemd::dropin_file { 'puppet.conf':
      unit           => $service_name,
      content        => epp('numad/etc/systemd/system/numad.service.d/puppet.conf.epp', $dropin_params),
      notify_service => true,
    }
  }

}
