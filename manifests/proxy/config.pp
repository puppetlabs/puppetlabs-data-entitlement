# @api private
class data_entitlement::proxy::config () {
  if !$data_entitlement::proxy::allow_trust_on_first_use {
    file { 'hdp-proxy private key':
      ensure  => file,
      path    => $data_entitlement::proxy::key_file,
      source  => "file:///etc/puppetlabs/puppet/ssl/private_keys/${trusted['certname']}.pem",
      owner   => $data_entitlement::proxy::user,
      mode    => '0600',
      require => Package[$data_entitlement::proxy::package],
    }

    file { 'hdp-proxy cert':
      ensure  => file,
      path    => $data_entitlement::proxy::cert_file,
      source  => "file:///etc/puppetlabs/puppet/ssl/certs/${trusted['certname']}.pem",
      owner   => $data_entitlement::proxy::user,
      mode    => '0600',
      require => Package[$data_entitlement::proxy::package],
    }

    file { 'hdp-proxy cacert':
      ensure  => file,
      path    => $data_entitlement::proxy::ca_cert_file,
      source  => 'file:///etc/puppetlabs/puppet/ssl/certs/ca.pem',
      owner   => $data_entitlement::proxy::user,
      mode    => '0600',
      require => Package[$data_entitlement::proxy::package],
    }
  }

  $proxy_config = {
    'admin' => {
      'prometheus' => {
        'namespace' => $data_entitlement::proxy::prometheus_namespace,
      },
      'timezone' => 'America/Los_Angeles',
    },
    'kv_store' => {
      'enabled' => false,
    },
    'ca_server' => $data_entitlement::proxy::ca_server,
    'ssl_dir' => $data_entitlement::proxy::ssl_dir,
    'dns_names' => [
      $data_entitlement::proxy::dns_name,
    ],
    'http' => {
      'upload' => {
        'enabled' => true,
        'port' => $data_entitlement::proxy::port,
        'no_tls' => false,
        'disable_client_auth' => false,
        'ca_cert_file' => $data_entitlement::proxy::ca_cert_file,
        'keyfile' => $data_entitlement::proxy::key_file,
        'certfile' => $data_entitlement::proxy::cert_file,
      },
      'query' => {
        'enabled' => false,
      },
      'metrics' => {
        'enabled' => false,
      },
    },
    'database' => {
      'enabled' => false,
    },
    'backends' => {
      'elasticsearch' => {
        'enabled' => false,
      },
      'redis' => {
        'enabled' => false,
      },
      'os' => {
        'enabled' => false,
      },
      'hdp' => {
        'address' => $data_entitlement::proxy::data_entitlement_address,
        'use_system_ca' => true,
        'token' => $data_entitlement::proxy::token.unwrap,
        'enabled' => true,
      },
    },
    'jobs' => {
      'enabled' => false,
    },
  }

  file {
    default:
      ensure => directory,
      owner  => $data_entitlement::proxy::user,
      group  => $data_entitlement::proxy::user,
      ;
    '/etc/puppetlabs/hdp-proxy':
      mode  => '0775',
      ;
    '/etc/puppetlabs/hdp-proxy/config':
      mode  => '0775',
      ;
    '/etc/puppetlabs/hdp-proxy/ssl':
      mode  => '0700',
      ;
    '/etc/puppetlabs/hdp-proxy/config/proxy.yaml':
      ensure  => file,
      mode    => '0440',
      content => to_yaml($proxy_config),
      ;
  }
}
