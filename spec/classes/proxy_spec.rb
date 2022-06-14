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
        it { is_expected.to contain_file('/opt/puppetlabs/data_entitlement').with_ensure('directory') }
        dir_list = [
          '/opt/puppetlabs/data_entitlement',
          '/opt/puppetlabs/data_entitlement/ssl',
        ]

        dir_list.each do |d|
          it {
            is_expected.to contain_file(d)
              .with_ensure('directory')
              .with_owner('11223')
              .with_group('11223')
          }
        end
      end

      context 'with specific version' do
        let(:params) do
          {
            'dns_name' => 'data_entitlement.test.com',
            'image_repository' => 'hub.docker.com',
            'image_prefix' => '',
            'version' => 'foo',
            'token' => sensitive('test-token'),
            'data_entitlement_address' => 'https://data_entitlement.com',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_file('/opt/puppetlabs/data_entitlement/proxy/docker-compose.yaml')
            .with_owner('root')
            .with_group('docker')
            .with_content(%r{hub.docker.com/data-ingestion:foo})
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
            is_expected.to contain_file('/opt/puppetlabs/data_entitlement/proxy/docker-compose.yaml')
              .with_content(%r{- "HDP_ADMIN_PROMETHEUS_NAMESPACE=foo"})
          }
        end
      end

      context 'extra hosts' do
        context 'set extra hosts' do
          let(:params) do
            {
              'dns_name' => 'data_entitlement.test.com',
              'token' => sensitive('test-token'),
              'data_entitlement_address' => 'https://data_entitlement.com',
              'prometheus_namespace' => 'foo',
              'extra_hosts' => { 'foo' => '127.0.0.1', 'bar' => '1.1.1.1' },
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_file('/opt/puppetlabs/data_entitlement/proxy/docker-compose.yaml')
              .with_content(%r{extra_hosts:})
          }
          it {
            is_expected.to contain_file('/opt/puppetlabs/data_entitlement/proxy/docker-compose.yaml')
              .with_content(%r{foo:127\.0\.0\.1})
          }
          it {
            is_expected.to contain_file('/opt/puppetlabs/data_entitlement/proxy/docker-compose.yaml')
              .with_content(%r{bar:1\.1\.1\.1})
          }
        end

        context 'no extra hosts' do
          let(:params) do
            {
              'dns_name' => 'data_entitlement.test.com',
              'token' => sensitive('test-token'),
              'data_entitlement_address' => 'https://data_entitlement.com',
              'prometheus_namespace' => 'foo',
              'extra_hosts' => {},
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_file('/opt/puppetlabs/data_entitlement/proxy/docker-compose.yaml')
              .without_content(%r{extra_hosts:})
          }
        end
      end

      context 'token, org, and region' do
        let(:params) do
          {
            'dns_name' => 'data_entitlement.test.com',
            'organization' => 'puppet',
            'region' => 'PDX',
            'token' => sensitive('$1$tokencity'),
            'data_entitlement_address' => 'https://data_entitlement.com',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_file('/opt/puppetlabs/data_entitlement/proxy/docker-compose.yaml')
            .with_content(%r{- "HDP_BACKENDS_HDP_ORGANIZATION=puppet"})
            .with_content(%r{- "HDP_BACKENDS_HDP_REGION=PDX"})
            .with_content(%r{- "HDP_BACKENDS_HDP_TOKEN=\$\$1\$\$tokencity"})
        }
      end
      context 'trust-on-first-use failures' do
        context 'Nothing specified' do
          let(:params) do
            {
              'dns_name' => 'data_entitlement.test.com',
              'token' => sensitive('$1$tokencity'),
              'data_entitlement_address' => 'https://data_entitlement.com',
              'allow_trust_on_first_use' => false,
              ## if ^ is false, we should fail compilation if certs keys and whatnot are not set.
            }
          end

          it { is_expected.to compile.and_raise_error(%r{.*}) }
        end
        context 'All specified' do
          let(:params) do
            {
              'dns_name' => 'data_entitlement.test.com',
              'token' => sensitive('$1$tokencity'),
              'data_entitlement_address' => 'https://data_entitlement.com',
              'allow_trust_on_first_use' => false,
              'ca_cert_file' => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
              'cert_file' => '/etc/puppetlabs/puppet/ssl/certs/data_entitlement.test.com.pem',
              'key_file' => '/etc/puppetlabs/puppet/ssl/private_keys/data_entitlement.test.com.pem',
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_file('/opt/puppetlabs/data_entitlement/proxy/docker-compose.yaml')
              .with_content(%r{- "HDP_HTTP_UPLOAD_CACERTFILE=/etc/puppetlabs/puppet/ssl/certs/ca\.pem"})
              .with_content(%r{- "HDP_HTTP_UPLOAD_CERTFILE=/etc/puppetlabs/puppet/ssl/certs/data_entitlement\.test\.com\.pem"})
              .with_content(%r{- "HDP_HTTP_UPLOAD_KEYFILE=/etc/puppetlabs/puppet/ssl/private_keys/data_entitlement\.test\.com\.pem"})
          }
        end
      end
    end
  end
end
