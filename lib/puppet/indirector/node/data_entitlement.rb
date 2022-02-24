require 'puppet/node'
require 'puppet/indirector/rest'

# HDP Indirector
class Puppet::Node::DataEntitlement < Puppet::Indirector::REST
  # Mock for find terminus call, just to match the interface
  def find(request); end

  # Mock for save terminus call, just to match the interface
  def save(request); end

  # Mock for destroy terminus call, just to match the interface
  def destroy(request); end
end
