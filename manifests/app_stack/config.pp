# @api private
class data_entitlement::app_stack::config () {
  ## Mount host certs if the dns_name is equal to the host's name, or
  ## if we set ui_use_tls to true, but don't provide key/cert file paths,
  $_mount_host_certs = $trusted['certname'] == $data_entitlement::app_stack::dns_name

  ## If we are going to be mounting host certs and keys,
  ## we need to run as the owner of these certs and keys in order to not break anything
  if $_mount_host_certs {
    $_final_data_entitlement_user = pick("${facts.dig('data_entitlement_health', 'puppet_user')}", '0')
  }

  ## Handle mounting certs for the UI - 
  ## Which involves HDP Query endpoints and the UI itself
  ## It is recommended that users user their own publically KI certs for these.
  ## If mount_host_certs is true, then we should use the host agents certs,
  ## but we also should for if ui_use_tls is enabled but no paths are provided.
  if $_mount_host_certs or ($data_entitlement::app_stack::ui_use_tls and !$data_entitlement::app_stack::ui_cert_file and !$data_entitlement::app_stack::ui_key_file) {
    $_final_ui_cert_file = "/etc/puppetlabs/puppet/ssl/certs/${trusted['certname']}.pem"
    $_final_ui_key_file = "/etc/puppetlabs/puppet/ssl/private_keys/${trusted['certname']}.pem"
  } else {
    $_final_ui_cert_file =  $data_entitlement::app_stack::ui_cert_file
    $_final_ui_key_file =  $data_entitlement::app_stack::ui_key_file
  }

  if $_mount_host_certs {
    $_final_cert_file = "/etc/puppetlabs/puppet/ssl/certs/${trusted['certname']}.pem"
    $_final_key_file = "/etc/puppetlabs/puppet/ssl/private_keys/${trusted['certname']}.pem"
  } else {
    $_final_cert_file = $data_entitlement::app_stack::cert_file
    $_final_key_file = $data_entitlement::app_stack::key_file
  }

  if !$data_entitlement::app_stack::allow_trust_on_first_use {
    ## All cert_file, key_file, and ca_cert_file must be set if 
    ## allow_trust_on_first_use is true.
    if !$_final_key_file {
      fail('Key file must be provided, or an untrusted download will occur')
    }
    if !$_final_cert_file {
      fail('Cert file must be provided, or an untrusted download will occur')
    }
    if !$data_entitlement::app_stack::ca_cert_file {
      fail('CA Cert file must be provided, or an untrusted download will occur')
    }
  }

  if !defined('$_final_data_entitlement_user') {
    $_final_data_entitlement_user = $data_entitlement::app_stack::data_entitlement_user
  }

  if $data_entitlement::app_stack::version {
    $_final_data_entitlement_version = $data_entitlement::app_stack::version
    $_final_ui_version = $data_entitlement::app_stack::version
    $_final_frontend_version = $data_entitlement::app_stack::version
  } else {
    $_final_data_entitlement_version = $data_entitlement::app_stack::data_entitlement_version
    unless $data_entitlement::app_stack::ui_version {
      $_final_ui_version = $data_entitlement::app_stack::data_entitlement_version
    } else {
      $_final_ui_version = $data_entitlement::app_stack::ui_version
    }
    unless $data_entitlement::app_stack::frontend_version {
      $_final_frontend_version = $data_entitlement::app_stack::data_entitlement_version
    } else {
      $_final_frontend_version = $data_entitlement::app_stack::frontend_version
    }
  }

  $_final_data_entitlement_s3_access_key = $data_entitlement::app_stack::data_entitlement_s3_access_key
  $_final_data_entitlement_s3_secret_key = $data_entitlement::app_stack::data_entitlement_s3_secret_key
  if $data_entitlement::app_stack::data_entitlement_manage_s3 {
    $_final_data_entitlement_s3_endpoint = 'http://minio:9000/'
    $_final_data_entitlement_s3_region = 'data_entitlement'
    $_final_data_entitlement_s3_facts_bucket = 'facts'
    $_final_data_entitlement_s3_disable_ssl = true
    $_final_data_entitlement_s3_force_path_style = true
  } else {
    $_final_data_entitlement_s3_endpoint = $data_entitlement::app_stack::data_entitlement_s3_endpoint
    $_final_data_entitlement_s3_region = $data_entitlement::app_stack::data_entitlement_s3_region
    $_final_data_entitlement_s3_facts_bucket = $data_entitlement::app_stack::data_entitlement_s3_facts_bucket
    $_final_data_entitlement_s3_disable_ssl = $data_entitlement::app_stack::data_entitlement_s3_disable_ssl
    $_final_data_entitlement_s3_force_path_style = $data_entitlement::app_stack::data_entitlement_s3_force_path_style
  }

  if $data_entitlement::app_stack::data_entitlement_manage_es {
    $_final_data_entitlement_es_username = undef
    $_final_data_entitlement_es_password = undef
    $_final_data_entitlement_es_host = 'http://elasticsearch:9200/'
  } else {
    $_final_data_entitlement_es_username = $data_entitlement::app_stack::data_entitlement_es_username
    $_final_data_entitlement_es_password = $data_entitlement::app_stack::data_entitlement_es_password
    $_final_data_entitlement_es_host = $data_entitlement::app_stack::data_entitlement_es_host
  }

  if $data_entitlement::app_stack::data_entitlement_query_auth == 'basic_auth' {
    if $data_entitlement::app_stack::data_entitlement_query_username == undef {
      fail('Basic auth requires username parameter to be set')
    }
    if $data_entitlement::app_stack::data_entitlement_query_password == undef {
      fail('Basic auth requires a query password to be set')
    }
  }
  if $data_entitlement::app_stack::data_entitlement_query_auth == 'oidc' {
    if $data_entitlement::app_stack::data_entitlement_query_oidc_issuer == undef {
      fail('OIDC Auth requires an issuer to validate tokens against')
    }
    if $data_entitlement::app_stack::data_entitlement_query_oidc_client_id == undef {
      fail('OIDC Auth requires a client ID to use')
    }
  }
  if $data_entitlement::app_stack::data_entitlement_query_auth == 'pe_rbac' {
    if $data_entitlement::app_stack::data_entitlement_query_pe_rbac_service == undef {
      fail('PE RBAC Auth requires an RBAC service to validate tokens against')
    }
    ## If PE RBAC is enabled,
    ## ca_cert_file must be set, or it won't work.
    ## we should attempt to use $_final_ca_cert_file,
    ## Which will use one that is downloaded insecurely during the trust-on-first-use step.
    if $data_entitlement::app_stack::data_entitlement_query_pe_rbac_ca_cert_file == undef {
      err('PE RBAC configured, but CA Cert not set - defaulting to downloaded CA Cert. Potentially insecure!')
      $_final_query_pe_rbac_ca_cert_file = $data_entitlement::app_stack::ca_cert_file
    } else {
      $_final_query_pe_rbac_ca_cert_file = $data_entitlement::app_stack::data_entitlement_query_pe_rbac_ca_cert_file
    }
  } else {
    $_final_query_pe_rbac_ca_cert_file = $data_entitlement::app_stack::data_entitlement_query_pe_rbac_ca_cert_file
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
    '/opt/puppetlabs/data_entitlement/ssl':
      mode  => '0700',
      ;
    '/opt/puppetlabs/data_entitlement/docker-compose.yaml':
      ensure  => file,
      mode    => '0440',
      owner   => 'root',
      group   => 'docker',
      content => epp('data_entitlement/docker-compose.yaml.epp', {
          'data_entitlement_version'                    => $_final_data_entitlement_version,
          'ui_version'                                  => $_final_ui_version,
          'frontend_version'                            => $_final_frontend_version,
          'image_prefix'                                => $data_entitlement::app_stack::image_prefix,
          'image_repository'                            => $data_entitlement::app_stack::image_repository,
          'data_entitlement_port'                       => $data_entitlement::app_stack::data_entitlement_port,
          'data_entitlement_ui_http_port'               => $data_entitlement::app_stack::data_entitlement_ui_http_port,
          'data_entitlement_ui_https_port'              => $data_entitlement::app_stack::data_entitlement_ui_https_port,
          'data_entitlement_query_port'                 => $data_entitlement::app_stack::data_entitlement_query_port,

          'data_entitlement_query_auth'                 => $data_entitlement::app_stack::data_entitlement_query_auth,
          'data_entitlement_query_username'             => $data_entitlement::app_stack::data_entitlement_query_username,
          'data_entitlement_query_password'             => $data_entitlement::app_stack::data_entitlement_query_password,
          'data_entitlement_query_oidc_issuer'          => $data_entitlement::app_stack::data_entitlement_query_oidc_issuer,
          'data_entitlement_query_oidc_client_id'       => $data_entitlement::app_stack::data_entitlement_query_oidc_client_id,
          'data_entitlement_query_oidc_audience'        => $data_entitlement::app_stack::data_entitlement_query_oidc_audience,
          'data_entitlement_query_pe_rbac_service'      => $data_entitlement::app_stack::data_entitlement_query_pe_rbac_service,
          'data_entitlement_query_pe_rbac_role_id'      => $data_entitlement::app_stack::data_entitlement_query_pe_rbac_role_id,
          'data_entitlement_query_pe_rbac_ca_cert_file' => $_final_query_pe_rbac_ca_cert_file,

          'elasticsearch_image'                         => $data_entitlement::app_stack::elasticsearch_image,
          'redis_image'                                 => $data_entitlement::app_stack::redis_image,
          'minio_image'                                 => $data_entitlement::app_stack::minio_image,

          'data_entitlement_manage_s3'                  => $data_entitlement::app_stack::data_entitlement_manage_s3,
          'data_entitlement_s3_endpoint'                => $_final_data_entitlement_s3_endpoint,
          'data_entitlement_s3_region'                  => $_final_data_entitlement_s3_region,
          'data_entitlement_s3_access_key'              => $_final_data_entitlement_s3_access_key,
          'data_entitlement_s3_secret_key'              => $_final_data_entitlement_s3_secret_key,
          'data_entitlement_s3_disable_ssl'             => $_final_data_entitlement_s3_disable_ssl,
          'data_entitlement_s3_facts_bucket'            => $_final_data_entitlement_s3_facts_bucket,
          'data_entitlement_s3_force_path_style'        => $_final_data_entitlement_s3_force_path_style,

          'data_entitlement_manage_es'                  => $data_entitlement::app_stack::data_entitlement_manage_es,
          'data_entitlement_es_host'                    => $_final_data_entitlement_es_host,
          'data_entitlement_es_username'                => $_final_data_entitlement_es_username,
          'data_entitlement_es_password'                => $_final_data_entitlement_es_password,

          'ca_server'                                   => $data_entitlement::app_stack::ca_server,
          'key_file'                                    => $_final_key_file,
          'cert_file'                                   => $_final_cert_file,
          'ca_cert_file'                                => $data_entitlement::app_stack::ca_cert_file,

          'ui_use_tls'                                  => $data_entitlement::app_stack::ui_use_tls,
          'ui_key_file'                                 => $_final_ui_key_file,
          'ui_cert_file'                                => $_final_ui_cert_file,
          'ui_ca_cert_file'                             => $data_entitlement::app_stack::ui_ca_cert_file,

          'dns_name'                                    => $data_entitlement::app_stack::dns_name,
          'dns_alt_names'                               => $data_entitlement::app_stack::dns_alt_names,
          'data_entitlement_user'                       => $_final_data_entitlement_user,
          'root_dir'                                    => '/opt/puppetlabs/data_entitlement',
          'max_es_memory'                               => $data_entitlement::app_stack::max_es_memory,
          'prometheus_namespace'                        => $data_entitlement::app_stack::prometheus_namespace,
          'access_log_level'                            => $data_entitlement::app_stack::access_log_level,
          'dashboard_url'                               => $data_entitlement::app_stack::dashboard_url,
          'extra_hosts'                                 => $data_entitlement::app_stack::extra_hosts,

          'mount_host_certs'                            => $_mount_host_certs,
        }
      ),
      ;
  }

  # If TLS is enabled, ensure certificate files are present before docker does
  # its thing and restart containers if the files change.
  if $data_entitlement::app_stack::ui_use_tls and $data_entitlement::app_stack::ui_cert_files_puppet_managed {
    File[$_final_ui_key_file] ~> Docker_compose['data_entitlement']
    File[$_final_ui_cert_file] ~> Docker_compose['data_entitlement']

    if $data_entitlement::app_stack::ui_ca_cert_file {
      File[$data_entitlement::app_stack::ui_ca_cert_file] ~> Docker_compose['data_entitlement']
    }
  }
}
