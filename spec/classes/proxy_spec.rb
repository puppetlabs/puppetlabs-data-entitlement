require 'spec_helper'

describe 'data_entitlement::proxy' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'dns_name' => 'data_entitlement.test.com',
          'token' => sensitive('token-town-usa'),
          'data_entitlement_address' => 'https://data_entitlement.com',
        }
      end

      context 'with defaults' do
        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_package('hdp-proxy')
            .with_ensure('latest')
        }
        it {
          is_expected.to contain_file('/etc/puppetlabs/hdp-proxy/config/proxy.yaml')
            .with_owner('hdp-proxy')
            .with_group('hdp-proxy')
        }

        dir_list = [
          '/etc/puppetlabs/hdp-proxy',
          '/etc/puppetlabs/hdp-proxy/config',
          '/etc/puppetlabs/hdp-proxy/ssl',
        ]

        dir_list.each do |d|
          it {
            is_expected.to contain_file(d)
              .with_ensure('directory')
              .with_owner('hdp-proxy')
              .with_group('hdp-proxy')
          }
        end
      end

      context 'with specific version' do
        let(:params) do
          {
            'dns_name' => 'data_entitlement.test.com',
            'version' => 'foo',
            'token' => sensitive('test-token'),
            'data_entitlement_address' => 'https://data_entitlement.com',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_package('hdp-proxy')
            .with_ensure('foo')
        }
      end

      context 'data_entitlement admin config options' do
        context 'set prometheus namespace' do
          let(:params) do
            {
              'dns_name' => 'data_entitlement.test.com',
              'token' => sensitive('test-token'),
              'data_entitlement_address' => 'https://data_entitlement.com',
              'prometheus_namespace' => 'foo',
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_file('/etc/puppetlabs/hdp-proxy/config/proxy.yaml')
              .with_content(%r{namespace: foo})
          }
        end
      end

      context 'token, org, and region' do
        let(:params) do
          {
            'dns_name' => 'data_entitlement.test.com',
            'token' => sensitive('$1$tokencity'),
            'data_entitlement_address' => 'https://data_entitlement.com',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_file('/etc/puppetlabs/hdp-proxy/config/proxy.yaml')
            .with_content(%r{token: "\$1\$tokencity"})
        }
      end
    end
  end
end
