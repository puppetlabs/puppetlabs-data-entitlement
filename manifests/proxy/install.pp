# @api private
class data_entitlement::proxy::install () {
  if $data_entitlement::proxy::create_docker_group and $data_entitlement::proxy::manage_docker {
    group { 'docker':
      ensure => 'present',
      before => Class['docker'],
    }
  }

  if $data_entitlement::proxy::manage_docker {
    class { 'docker':
      docker_users => $data_entitlement::proxy::docker_users,
      log_driver   => $data_entitlement::proxy::log_driver,
    }
    -> class { 'docker::compose':
      ensure  => present,
      version => $data_entitlement::proxy::compose_version,
    }
  }
}
