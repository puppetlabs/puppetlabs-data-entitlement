# @api private
class data_entitlement::proxy::service {
  service { $data_entitlement::proxy::service :
    ensure => $data_entitlement::proxy::service_status,
    enable => $data_entitlement::proxy::service_enabled,
  }
}
