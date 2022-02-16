#
# This class takes care of configuring a node to run an HDP Proxy/Gateway.
#
# @param [Boolean] create_docker_group
#   Ensure the docker group is present.
#
# @param [Boolean] manage_docker
#   Install and manage docker as part of app_stack
#
# @param [String[1]] log_driver
#   The log driver Docker will use
#
# @param [Integer] data_entitlement_port
#   Port to access HDP upload service
#
# @param [String[1]] data_entitlement_user
#   User to run HDP proxy as. 
#   Set to puppet if certname == dns_name
#   
# @param [String[1]] compose_version
#   The version of docker-compose to install
#
# @param [Optional[Array[String[1]]]] docker_users
#   Users to be added to the docker group on the system
#
# @param [Optional[String[1]]] image_repository
#   Image repository to pull images from - defaults to gcr.io/hdp-gcp-316600/, which is where HDP images are hosted.
#   Can be used for airgapped environments/testing environments
#
# @param [String] image_prefix
#   Prefix that comes before each image
#   Can be used for easy name spacing under the same repository
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
# @param [Optional[String[1]]] client_ca_cert_file
#   When submitting to the remote HDP, use this CA to validate the server.
#   Should not be used in production - system CAs are fine.
#
# @param [Optional[String[1]]] client_key_file
#   When submitting to the remote HDP, use this key file as client auth.
#
# @param [Optional[String[1]]] client_cert_file
#   When submitting to the remote HDP, use this cert file as client auth.
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
# @param [Hash[String[1], String[1]]] extra_hosts
#    This parameter can be used to set hostname mappings in docker-compose file.
#    Can be used to mimic the /etc/hosts techniques commonly used in puppet.
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
# @param [Optional[String[1]]] region
#    A region UUID for an HDP region. 
#    The HDP Proxy will attempt to submit this data under this region if it is permitted to submit data under multiple regions, 
#    or the HDP service is set to "relaxed" auth.
#
# @param [Optional[String[1]]] organization
#    An organization UUID for HDP. 
#    The HDP Proxy will attempt to submit its data under this organization, 
#    but the HDP service will not respect this unless it is in "relaxed" auth mode (which, if you're reading this, it's not).
#
# @example Configure via Hiera
#   include data_entitlement::app_stack
#
# @example Manage the docker group elsewhere
#   realize(Group['docker'])
#
#   class { 'data_entitlement::app_stack':
#     dns_name            => 'http://data_entitlement-app.example.com',
#     create_docker_group => false,
#     require             => Group['docker'],
#   }
#
class data_entitlement::proxy (
  String[1] $dns_name,
  Stdlib::HTTPUrl $data_entitlement_address,
  Sensitive[String[1]] $token,

  Array[String[1]] $dns_alt_names = [],

  Boolean $create_docker_group = true,
  Boolean $manage_docker = true,
  String[1] $log_driver = 'journald',
  Integer $data_entitlement_port = 9091,

  String[1] $data_entitlement_user = '11223',
  String[1] $compose_version = '1.25.0',
  Optional[Array[String[1]]] $docker_users = undef,
  Optional[String[1]] $image_repository = "gcr.io/hdp-gcp-316600",
  String $image_prefix = 'puppet/hdp-',
  Optional[String[1]] $version = 'latest',

  ## Either one of these two options can be configured
  Optional[String[1]] $ca_server = undef,

  Boolean $allow_trust_on_first_use = true,
  Optional[String[1]] $ca_cert_file = undef,
  Optional[String[1]] $key_file = undef,
  Optional[String[1]] $cert_file = undef,

  Optional[String[1]] $client_ca_cert_file = undef,
  Optional[String[1]] $client_key_file = undef,
  Optional[String[1]] $client_cert_file = undef,

  Optional[String[1]] $region = undef,
  Optional[String[1]] $organization = undef,

  Hash[String[1], String[1]] $extra_hosts = {},
  String[1] $prometheus_namespace = 'data_entitlement',
) {
  contain data_entitlement::proxy::install
  contain data_entitlement::proxy::config
  contain data_entitlement::proxy::service

  Class['data_entitlement::proxy::install']
  -> Class['data_entitlement::proxy::config']
  -> Class['data_entitlement::proxy::service']
}
