#
# This class takes care of configuring a node to run an HDP Proxy/Gateway.
#
# @param [Integer] port
#   Port to run HDP upload service on
#   Defaults to 9091
#
# @param [String[1]] user
#   User to run HDP proxy as. 
#   Defaults to hdp-proxy
#
# @param [Optional[String[1]]] ca_server
#   URL of Puppet CA Server. If no keys/certs are provided, then 
#   HDP will attempt to provision its own certs and get them signed.
#   Either this or ca_cert_file/key_file/cert_file can be specified.
#   If autosign is not enabled, HDP will wait for the certificate to be signed
#   by a puppet administrator
#
# @param [Boolean] allow_trust_on_first_use
#   If true, then the HDP will download the CA and setup its certs and keys from the server if they haven't been provided.
#   Since the HDP doesn't have any CA before starting this process, it will automatically trust the first server that appears as
#   ca_server. If you don't explicitly set this value to true, then this module will not deploy an HDP installation without being given
#   ca_cert_file, key_file, and cert_file.
#
# @param [Optional[String[1]]] ssl_dir
#   The ssl dir for certificates
#   Defaults to /etc/puppetlabs/hdp-proxy/ssl
#
# @param [Optional[String[1]]] ca_cert_file
#   CA certificate to validate connecting clients
#   This or ca_server can be specified
#
# @param [Optional[String[1]]] key_file
#   Private key for cert_file - pem encoded.
#   This or ca_server can be specified
#
# @param [Optional[String[1]]] cert_file
#   Puppet PKI cert file - pem encoded.
#   This or ca_server can be specified
#
# @param [String[1]] dns_name
#   Name that puppet server will find HDP at.
#   Should match the names in cert_file if provided.
#   If ca_server is used instead, this name will be used as certname.
#
# @param [Array[String[1]]] dns_alt_names
#   Extra dns names attached to the puppet cert, can be used to bypass certname collisions
#
# @param [Optional[String[1]]] version
#   The version to use of the HDP Proxy.
#   Defaults to latest
#
# @param [String[1]] prometheus_namespace
#   The HDP data service exposes some internal prometheus metrics.
#   This variable can be used to change the HDP's prom metric namespace.
#
# @param [Sensitive[String[1]]] token
#    The HDP's access token. Gathered from the the HDP UI when creating this proxy.
#
# @param [Stdlib::HTTPUrl] data_entitlement_address
#    The URL of the HDP endpoint to send data to.
#
# @param [Optional[String[1]]] package
#   The HDP proxy package name
#   Defaults to hdp-proxy
#
# @param [Optional[String[1]]] service
#   The name of the HDP proxy service.
#   Defaults to hdp-proxy
#
# @param [Optional[String[1]]] service_status
#   Indicates whether the HDP proxy service should be running or stopped
#   Defaults to running
#
# @param [Optional[String[1]]] service_enabled
#   Indicates whether the HDP proxy service should be enabled
#   Defaults to true
#
# @example Configure via Hiera
#   include data_entitlement::proxy
#
class data_entitlement::proxy (
  Sensitive[String[1]] $token,

  Stdlib::HTTPUrl $data_entitlement_address = 'https://hdp-upload-staging.prod.paas.puppet.net',
  Array[String[1]] $dns_alt_names = [],

  String[1] $ca_server = 'puppet',
  String[1] $dns_name = 'hdp-proxy',
  Integer $port = 9091,

  String[1] $user = 'hdp-proxy',
  String[1] $version = 'latest',

  Boolean $allow_trust_on_first_use = false,
  String[1] $ssl_dir = '/etc/puppetlabs/hdp-proxy/ssl',
  String[1] $ca_cert_file = "${data_entitlement::proxy::ssl_dir}/ca.cert.pem",
  String[1] $key_file = "${data_entitlement::proxy::ssl_dir}/data-ingestion.key.pem",
  String[1] $cert_file = "${data_entitlement::proxy::ssl_dir}/data-ingestion.cert.pem",

  String[1] $prometheus_namespace = 'hdp_proxy',

  String[1] $package         = 'hdp-proxy',
  String[1] $service         = 'hdp-proxy',
  String[1] $service_status  = 'running',
  Boolean   $service_enabled = true,

) {
  contain data_entitlement::proxy::install
  contain data_entitlement::proxy::config
  contain data_entitlement::proxy::service

  Class['data_entitlement::proxy::install']
  ~> Class['data_entitlement::proxy::config']
  ~> Class['data_entitlement::proxy::service']
}
