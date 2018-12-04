require 'spec_helper'

describe 'sap::config::mount_point' do
  context 'missing mount type' do
    let(:title) { '/missing/mount/type' }
    let(:params) do
      {
        file_params: {
          owner: 'root',
          group: 'root',
          mode: '0755',
        },
        mount_parameters: {
          managed: true,
          garbage: 'somegarbage',
        },
      }
    end

    it { is_expected.to compile.with_all_deps.and_raise_error(%r{mount_point: missing mount type for path '#{title}'!}) }
  end

  context 'invalid mount type' do
    let(:title) { '/bad/type' }
    let(:params) do
      {
        file_params: {
          owner: 'root',
          group: 'root',
          mode: '0755',
        },
        mount_parameters: {
          managed: true,
          type: 'cool-bad-type',
        },
      }
    end

    it { is_expected.to compile.with_all_deps.and_raise_error(%r{mount_point: invalid mount type 'cool-bad-type' for path '#{title}'!}) }
  end

  context 'sid specific but missing sid pattern' do
    let(:title) { '/missing/sid/pattern' }
    let(:params) do
      {
        sid: 'ECP',
        file_params: {
          owner: 'root',
          group: 'root',
          mode: '0755',
        },
      }
    end

    it { is_expected.to compile.with_all_deps.and_raise_error(%r{mount_point: SID specified for '#{title}' but does not contain '_sid_' or '_SID_'!}) }
  end

  context 'count missing substring' do
    let(:title) { '/missing/count/pattern' }
    let(:params) do
      {
        count: 7,
        file_params: {
          owner: 'root',
          group: 'root',
          mode: '0755',
        },
      }
    end

    it { is_expected.to compile.with_all_deps.and_raise_error(%r{mount_point: '#{title}' specifies \$count but does not contain '_N_'!}) }
  end

  context 'count too small' do
    let(:title) { '/small/count/_N_' }
    let(:params) do
      {
        mount_path: '/small/count/_N_',
        count: 0,
        file_params: {
          owner: 'root',
          group: 'root',
          mode: '0755',
        },
      }
    end

    it { is_expected.to compile.with_all_deps.and_raise_error(%r{mount_point: '#{title}' specifies \$count not >= 1!}) }
  end

  context 'nfsv4 missing server' do
    let(:title) { '/sapmnt/_SID_' }
    let(:params) do
      {
        sid: 'ECP',
        file_params: {
          owner: 'root',
          group: 'root',
          mode: '0755',
        },
        mount_parameters: {
          managed: true,
          type: 'nfsv4',
        },
      }
    end

    it { is_expected.to compile.with_all_deps.and_raise_error(%r{mount_point: '#{title}' type 'nfsv4' missing 'server'!}) }
  end

  context 'nfsv4 missing share' do
    let(:title) { '/sapmnt/_SID_' }
    let(:params) do
      {
        sid: 'ECP',
        file_params: {
          owner: 'root',
          group: 'root',
          mode: '0755',
        },
        mount_parameters: {
          managed: true,
          type: 'nfsv4',
          server: 'nfs.example.org',
        },
      }
    end

    it { is_expected.to compile.with_all_deps.and_raise_error(%r{mount_point: '#{title}' type 'nfsv4' missing 'share'!}) }
  end

  context 'sid specific path' do
    let(:title) { '/sapmnt/_SID_' }
    let(:params) do
      {
        mount_path: '/sapmnt/_SID_',
        sid: 'ECP',
        sid_upper_pattern: '_SID_',
        sid_lower_pattern: '_sid_',
        file_params: {
          owner: '_sid_adm',
          group: 'sapsys',
          mode: '0755',
        },
      }
    end

    it { is_expected.to compile.with_all_deps }

    it {
      is_expected.to contain_file('/sapmnt/ECP').with(
        ensure: 'directory',
        owner: 'ecpadm',
        group: 'sapsys',
        mode: '0755',
      )
    }
  end

  context 'sid specific path with count' do
    let(:title) { '/sapmnt/_SID_' }
    let(:params) do
      {
        mount_path: '/db2/_SID_/sapdata_N_',
        sid: 'ECP',
        count: 4,
        sid_upper_pattern: '_SID_',
        sid_lower_pattern: '_sid_',
        file_params: {
          owner: 'db2_sid_',
          group: 'db_sid_adm',
          mode: '0750',
        },
      }
    end

    it { is_expected.to compile.with_all_deps }

    it {
      is_expected.to contain_file('/db2/ECP/sapdata1').with(
        ensure: 'directory',
        owner: 'db2ecp',
        group: 'dbecpadm',
        mode: '0750',
      )
      is_expected.to contain_file('/db2/ECP/sapdata2').with(
        ensure: 'directory',
        owner: 'db2ecp',
        group: 'dbecpadm',
        mode: '0750',
      )
      is_expected.to contain_file('/db2/ECP/sapdata3').with(
        ensure: 'directory',
        owner: 'db2ecp',
        group: 'dbecpadm',
        mode: '0750',
      )
      is_expected.to contain_file('/db2/ECP/sapdata4').with(
        ensure: 'directory',
        owner: 'db2ecp',
        group: 'dbecpadm',
        mode: '0750',
      )
    }
  end

  test_on = {
    hardwaremodels: ['x86_64', 'ppc64'],
    supported_os: [
      {
        'operatingsystem' => 'RedHat',
        'operatingsystemrelease' => ['7'],
      },
    ],
  }

  on_supported_os(test_on).each do |os, facts|
    context "on os #{os} sid specific nfs mount" do
      let(:title) { '/sapmnt/_SID_' }
      let(:facts) { facts }
      let(:params) do
        {
          mount_path: '/sapmnt/_SID_',
          sid: 'ECP',
          sid_upper_pattern: '_SID_',
          sid_lower_pattern: '_sid_',
          file_params: {
            owner: '_sid_adm',
            group: 'sapsys',
            mode: '0755',
          },
          mount_parameters: {
            managed: true,
            type: 'nfsv4',
            share: '/srv/nfs/sapmnt/_SID_',
            server: 'nfs.example.com',
          },
          mount_defaults: {
            nfsv4: {
              options: 'rw,soft,noac,timeo=200,retans=3,proto=tcp',
            },
          },
        }
      end
      let(:pre_condition) do
        'class { nfs:
          server_enabled => false,
          client_enabled => true,
          nfs_v4_client => true,
          nfs_v4_idmap_domain => "example.com",
        }'
      end

      it { is_expected.to compile.with_all_deps }

      it {
        is_expected.to contain_nfs__client__mount('/sapmnt/ECP').with(
          ensure: 'mounted',
          server: 'nfs.example.com',
          share: '/srv/nfs/sapmnt/ECP',
          atboot: true,
          options_nfsv4: 'rw,soft,noac,timeo=200,retans=3,proto=tcp',
          owner: 'ecpadm',
          group: 'sapsys',
          mode: '0755',
        )
      }
    end
  end
end
