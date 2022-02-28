require 'fileutils'
require 'uri'
require 'yaml'
require 'json'
require 'time'
require 'puppet'
require 'puppet/util'
require 'puppet/util/puppetdb'
require 'puppet/util/puppetdb/command'
require 'puppet/util/puppetdb/command_names'
require 'puppet/util/puppetdb/char_encoding'
require 'puppet/node/facts'

# Utility functions used by the report processor and the facts indirector.
module Puppet::Util::DataEntitlement
  ## The default command URL for puppetDB
  CommandsUrl = Puppet::Util::Puppetdb::Command::CommandsUrl
  ## The command for replacing facts in puppetDB
  CommandReplaceFacts = Puppet::Util::Puppetdb::CommandNames::CommandReplaceFacts

  ## Comment for CI - Read the settings out of a file...
  def settings
    return @settings if @settings
    @settings_file = Puppet[:confdir] + '/data_entitlement.yaml'
    @settings = YAML.load_file(@settings_file)
  end

  ## comment for get_trusted_info
  def get_trusted_info(node)
    trusted = Puppet.lookup(:trusted_information) do
      Puppet::Context::TrustedInformation.local(node)
    end
    trusted.to_h
  end

  ## A valauble place for a comment
  ## The HDP has a similar interface to puppetDB,
  ## This code is ripped out of PuppetDB's terminus, and it is used to actually post data to the HDP.
  ## Everything in PuppetDB is a "command", but really these are just for submitting documents.
  def submit_command_to_data_entitlement(host, command, version, certname, producer_timestamp_utc, payload)
    checksum_payload = Puppet::Util::Puppetdb::CharEncoding.utf8_string({
      command: command,
      version: version,
      certname: certname,
      payload: payload,
    }.to_pson, "Error encoding a '#{command}' command for host '#{certname}'")

    command = Puppet::Util::Puppetdb::CharEncoding.coerce_to_utf8(command).tr(' ', '_')
    checksum = Digest::SHA1.hexdigest(checksum_payload)

    params = "checksum=#{checksum}&version=#{version}&certname=#{certname}&command=#{command}&producer-timestamp=#{producer_timestamp_utc.iso8601(3)}"

    url = "#{host}#{CommandsUrl}?#{params}"
    uri = URI.parse(url)

    headers = { 'Content-Type' => 'application/json' }
    client = Puppet.runtime[:http]
    response = client.post(uri, payload.to_json, headers: headers, options: {
                             read_timeout: 5,
                             open_timeout: 5,
                             ssl_timeout: 5,
                             compress: :gzip,
                             ssl_context: nil, ## nil context forces client cert + puppet PKI verification
                           })

    Puppet.err _('HDP unable to submit data to %{uri} [%{code}] %{message}') % { uri: uri.path, code: response.code, message: response.body } unless response.code == 200 || response.code == 404
  end

  ## A helper function to submit facts with a set_facts command.
  def submit_facts(host, request, _time)
    current_time = Time.now

    payload = profile('Encode facts command submission payload',
                      [:data_entitlement, :facts, :encode]) do
      facts = request.instance.dup
      facts.values = facts.values.dup
      facts.values[:trusted] = get_trusted_info(request.node)

      inventory = facts.values['_puppet_inventory_1']
      package_inventory = inventory['packages'] if inventory.respond_to?(:keys)
      facts.values.delete('_puppet_inventory_1')

      payload_value = {
        'certname' => facts.name,
        'values' => facts.values,
        'environment' => request.options[:environment] || request.environment.to_s,
        'producer_timestamp' => Puppet::Util::Puppetdb.to_wire_time(current_time),
        'producer' => Puppet[:node_name_value],
      }

      if inventory
        payload_value['package_inventory'] = package_inventory
      end

      payload_value
    end

    submit_command_to_data_entitlement(host, CommandReplaceFacts, 5, request.key, current_time.clone.utc, payload)
  end
end
