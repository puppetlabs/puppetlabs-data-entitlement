require 'spec_helper'

describe 'data_entitlement::data_processor' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:pre_condition) { "service { 'pe-puppetserver': }" }

      context 'with a data_entitlement_url string value' do
        let(:params) do
          {
            'data_entitlement_url' => 'https://data_entitlement.example.com:9091',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('data_entitlement::resource_collector') }
        it {
          is_expected.to contain_file('/etc/puppetlabs/puppet/data_entitlement.yaml')
            .with_content(%r{'data_entitlement_urls':\n  - 'https://data_entitlement.example.com:9091'\n'})
        }
        it {
          is_expected.to contain_file('/etc/puppetlabs/data_entitlement')
            .with_ensure('directory')
            .with_owner('pe-puppet')
            .with_group('pe-puppet')
        }
        it {
          is_expected.to contain_file('/etc/puppetlabs/data_entitlement/data_entitlement_routes.yaml')
            .with_ensure('file')
            .with_owner('pe-puppet')
            .with_group('pe-puppet')
            .with_content(%r{    terminus: "data_entitlement"})
            .with_content(%r{    cache: "data_entitlement"})
            .that_notifies('Service[pe-puppetserver]')
        }
        it {
          is_expected.to contain_ini_setting('enable data_entitlement_routes.yaml')
            .with_path('/etc/puppetlabs/puppet/puppet.conf')
            .with_section('master')
            .with_setting('route_file')
            .with_value('/etc/puppetlabs/data_entitlement/data_entitlement_routes.yaml')
            .that_requires('File[/etc/puppetlabs/data_entitlement/data_entitlement_routes.yaml]')
            .that_notifies('Service[pe-puppetserver]')
        }
        it { is_expected.to contain_ini_setting('puppetdb_submit_only_server_urls').with_ensure('absent') }
      end

      context 'with a data_entitlement_url array value' do
        let(:params) do
          {
            'data_entitlement_url' => [
              'https://data_entitlement-prod.example.com:9091',
              'https://data_entitlement-stage.example.com:9091',
            ],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_file('/etc/puppetlabs/puppet/data_entitlement.yaml')
            .with_content(%r{'data_entitlement_urls':\n  - 'https://data_entitlement-prod.example.com:9091'\n  - 'https://data_entitlement-stage.example.com:9091'\n})
        }
      end

      context 'with a keep_node_re value' do
        let(:params) do
          {
            'data_entitlement_url' => 'https://data_entitlement-prod.example.com:9091',
            'keep_node_re' => '^a.*',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_file('/etc/puppetlabs/puppet/data_entitlement.yaml')
            .with_content(%r{^'keep_nodes': '\^a\.\*'\n})
        }
      end

      context 'with collection_method set to pdb_submit_only_server_urls' do
        let(:params) do
          {
            'data_entitlement_url' => 'https://data_entitlement-prod.example.com:9091',
            'collection_method' => 'pdb_submit_only_server_urls',
          }
        end

        it {
          is_expected.to contain_file('/etc/puppetlabs/puppet/data_entitlement.yaml')
            .with_ensure('absent')
            .that_notifies('Service[pe-puppetserver]')
        }
        it {
          is_expected.to contain_file('/etc/puppetlabs/data_entitlement/data_entitlement_routes.yaml')
            .with_ensure('absent')
            .that_notifies('Service[pe-puppetserver]')
        }
        it {
          is_expected.to contain_ini_setting('remove routes_file setting from puppet.conf')
            .with_ensure('absent')
            .with_path('/etc/puppetlabs/puppet/puppet.conf')
            .with_section('master')
            .with_setting('route_file')
            .that_notifies('Service[pe-puppetserver]')
        }

        context 'with a single data_entitlement_url' do
          let(:params) do
            {
              'data_entitlement_url' => 'https://data_entitlement-prod.example.com:9091',
              'collection_method' => 'pdb_submit_only_server_urls',
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_ini_setting('puppetdb_submit_only_server_urls')
              .with_path('/etc/puppetlabs/puppet/puppetdb.conf')
              .with_section('main')
              .with_setting('submit_only_server_urls')
              .with_value('https://data_entitlement-prod.example.com:9091')
              .that_notifies('Service[pe-puppetserver]')
          }
        end

        context 'with an array for data_entitlement_url' do
          let(:params) do
            {
              'data_entitlement_url' => [
                'https://data_entitlement-prod.example.com:9091',
                'https://data_entitlement-stage.example.com:9091',
              ],
              'collection_method' => 'pdb_submit_only_server_urls',
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_ini_setting('puppetdb_submit_only_server_urls')
              .with_path('/etc/puppetlabs/puppet/puppetdb.conf')
              .with_section('main')
              .with_setting('submit_only_server_urls')
              .with_value('https://data_entitlement-prod.example.com:9091,https://data_entitlement-stage.example.com:9091')
              .that_notifies('Service[pe-puppetserver]')
          }
        end

        context 'with multiple pdb_submit_only_server_urls' do
          let(:params) do
            {
              'data_entitlement_url' => 'https://data_entitlement-prod.example.com:9091',
              'collection_method' => 'pdb_submit_only_server_urls',
              'pdb_submit_only_server_urls' => [
                'https://additional-destination1.example.com',
                'https://additional-destination2.example.com',
              ],
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_ini_setting('puppetdb_submit_only_server_urls')
              .with_path('/etc/puppetlabs/puppet/puppetdb.conf')
              .with_section('main')
              .with_setting('submit_only_server_urls')
              .with_value('https://additional-destination1.example.com,https://additional-destination2.example.com,https://data_entitlement-prod.example.com:9091')
              .that_notifies('Service[pe-puppetserver]')
          }
        end

        context 'with pdb_submit_only_server_urls and duplicate entries' do
          # This validates that the unique function is working as anticipated when combining
          # data_entitlement_url with pdb_submit_only_server_urls
          let(:params) do
            {
              'data_entitlement_url' => 'https://data_entitlement-prod.example.com:9091',
              'collection_method' => 'pdb_submit_only_server_urls',
              'pdb_submit_only_server_urls' => [
                'https://data_entitlement-prod.example.com:9091',
                'https://additional-destination.example.com',
              ],
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_ini_setting('puppetdb_submit_only_server_urls')
              .with_path('/etc/puppetlabs/puppet/puppetdb.conf')
              .with_section('main')
              .with_setting('submit_only_server_urls')
              .with_value('https://data_entitlement-prod.example.com:9091,https://additional-destination.example.com')
              .that_notifies('Service[pe-puppetserver]')
          }
        end
      end
    end
  end
end
