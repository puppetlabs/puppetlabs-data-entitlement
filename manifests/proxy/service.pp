# @api private
class data_entitlement::proxy::service {
  docker_compose { 'data_entitlement-proxy':
    ensure        => present,
    compose_files => ['/opt/puppetlabs/data_entitlement/proxy/docker-compose.yaml',],
    require       => File['/opt/puppetlabs/data_entitlement/proxy/docker-compose.yaml'],
    subscribe     => File['/opt/puppetlabs/data_entitlement/proxy/docker-compose.yaml'],
  }
}
