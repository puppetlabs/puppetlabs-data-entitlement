# @api private
class data_entitlement::proxy::config () {
  $_mount_host_certs = $trusted['certname'] == $data_entitlement::proxy::dns_name
  if $_mount_host_certs {
    $_final_data_entitlement_user = pick("${facts.dig('data_entitlement_health', 'puppet_user')}", '0')
    $_final_cert_file = "/etc/puppetlabs/puppet/ssl/certs/${trusted['certname']}.pem"
    $_final_key_file = "/etc/puppetlabs/puppet/ssl/private_keys/${trusted['certname']}.pem"
  } else {
    $_final_data_entitlement_user = $data_entitlement::proxy::data_entitlement_user
    $_final_cert_file =  $data_entitlement::proxy::cert_file
    $_final_key_file =  $data_entitlement::proxy::key_file
  }

  if !$data_entitlement::proxy::allow_trust_on_first_use {
    ## All cert_file, key_file, and ca_cert_file must be set if 
    ## allow_trust_on_first_use is true.
    if !$_final_key_file {
      fail('Key file must be provided, or an untrusted download will occur')
    }
    if !$_final_cert_file {
      fail('Cert file must be provided, or an untrusted download will occur')
    }
    if !$data_entitlement::proxy::ca_cert_file {
      fail('CA Cert file must be provided, or an untrusted download will occur')
    }
  }

  file {
    default:
      ensure  => directory,
      owner   => $_final_data_entitlement_user,
      group   => $_final_data_entitlement_user,
      require => Group['docker'],
      ;
    '/opt/puppetlabs/data_entitlement':
      mode  => '0775',
      ;
    '/opt/puppetlabs/data_entitlement/proxy':
      mode  => '0775',
      ;
    '/opt/puppetlabs/data_entitlement/ssl':
      mode  => '0700',
      ;
    '/opt/puppetlabs/data_entitlement/proxy/docker-compose.yaml':
      ensure  => file,
      mode    => '0440',
      owner   => 'root',
      group   => 'docker',
      content => epp('data_entitlement/data-proxy-docker-compose.yaml.epp', {
          'data_entitlement_version' => $data_entitlement::proxy::version,
          'image_prefix'             => $data_entitlement::proxy::image_prefix,
          'image_repository'         => $data_entitlement::proxy::image_repository,
          'data_entitlement_port'    => $data_entitlement::proxy::data_entitlement_port,

          'ca_server'                => $data_entitlement::proxy::ca_server,
          'key_file'                 => $data_entitlement::proxy::key_file,
          'cert_file'                => $data_entitlement::proxy::cert_file,
          'ca_cert_file'             => $data_entitlement::proxy::ca_cert_file,
          'client_key_file'          => $data_entitlement::proxy::client_key_file,
          'client_cert_file'         => $data_entitlement::proxy::client_cert_file,
          'client_ca_cert_file'      => $data_entitlement::proxy::client_ca_cert_file,

          'dns_name'                 => $data_entitlement::proxy::dns_name,
          'dns_alt_names'            => $data_entitlement::proxy::dns_alt_names,
          'data_entitlement_user'    => $_final_data_entitlement_user,
          'root_dir'                 => '/opt/puppetlabs/data_entitlement',
          'prometheus_namespace'     => $data_entitlement::proxy::prometheus_namespace,
          'extra_hosts'              => $data_entitlement::proxy::extra_hosts,

          'data_entitlement_address' => $data_entitlement::proxy::data_entitlement_address,
          'token'                    => $data_entitlement::proxy::token,
          'organization'             => $data_entitlement::proxy::organization,
          'region'                   => $data_entitlement::proxy::region,

          'mount_host_certs'         => $_mount_host_certs,
        }
      ),
      ;
  }
}
