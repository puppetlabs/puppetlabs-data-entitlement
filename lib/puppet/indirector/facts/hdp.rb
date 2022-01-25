require 'puppet/node/facts'
require 'puppet/indirector/facts/puppetdb'
require 'puppet/indirector/facts/yaml'
require 'puppet/util/data_entitlement'
require 'json'
require 'time'

# HDP Facts
class Puppet::Node::Facts::Hdp < Puppet::Node::Facts::Puppetdb
  desc 'Save facts to HDP, then Puppetdb.'

  include Puppet::Util::Hdp

  def save(request)
    begin
      Puppet.info 'Submitting facts to HDP'
      current_time = Time.now

      keep_nodes_re = Regexp.new(settings['keep_nodes'])

      if keep_nodes_re.match(request.instance.name)
        data_entitlement_urls = settings['data_entitlement_urls']
        data_entitlement_urls.each do |host|
          submit_facts(host, request, current_time.utc)
        end
      end
    rescue StandardError => e
      Puppet.err "Could not send facts to HDP: #{e}
#{e.backtrace}"
    end
    ## Data has been sent to HDP - now delete our data_entitlement facts and forward to puppetdb
    r = request.instance.dup
    r.values = r.values.dup
    r.values.delete('data_entitlement')
    request.instance = r
    super(request)
  end
end
