# @api private
class data_entitlement::app_stack::service {
  docker_compose { 'data_entitlement':
    ensure        => present,
    compose_files => ['/opt/puppetlabs/data_entitlement/docker-compose.yaml',],
    require       => File['/opt/puppetlabs/data_entitlement/docker-compose.yaml'],
    subscribe     => File['/opt/puppetlabs/data_entitlement/docker-compose.yaml'],
  }
}
