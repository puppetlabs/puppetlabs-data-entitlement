# @api private
class data_entitlement::proxy::install () {
  package { $data_entitlement::proxy::package :
    ensure => $data_entitlement::proxy::version,
    notify => Service[$data_entitlement::proxy::service],
  }
}
