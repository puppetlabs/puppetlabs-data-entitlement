# @api private
class data_entitlement::proxy::install () {
  package { $data_entitlement::proxy::package :
    ensure => $data_entitlement::proxy::proxy_version,
    notify => Service[$data_entitlement::proxy::service],
  }
}
