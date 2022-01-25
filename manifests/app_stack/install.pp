# @api private
class data_entitlement::app_stack::install () {
  if $data_entitlement::app_stack::create_docker_group and $data_entitlement::app_stack::manage_docker {
    group { 'docker':
      ensure => 'present',
      before => Class['docker'],
    }
  }

  if $data_entitlement::app_stack::manage_docker {
    class { 'docker':
      docker_users => $data_entitlement::app_stack::docker_users,
      log_driver   => $data_entitlement::app_stack::log_driver,
      root_dir     => $data_entitlement::app_stack::data_dir,
    }
    -> class { 'docker::compose':
      ensure  => present,
      version => $data_entitlement::app_stack::compose_version,
    }
  }
}
