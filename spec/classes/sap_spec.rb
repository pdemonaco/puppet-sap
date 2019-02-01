require 'spec_helper'

describe 'sap', type: :class do
  test_on = {
    hardwaremodels: ['x86_64', 'ppc64'],
    supported_os: [
      {
        'operatingsystem' => 'RedHat',
        'operatingsystemrelease' => ['7'],
      },
      {
        'operatingsystem' => 'CentOS',
        'operatingsystemrelease' => ['6', '7'],
      },
      {
        'operatingsystem' => 'OracleLinux',
        'operatingsystemrelease' => ['6', '7'],
      },
      {
        'operatingsystem' => 'Scientific',
        'operatingsystemrelease' => ['6', '7'],
      },
    ],
  }

  on_supported_os(test_on).each do |os, facts|
    context "on #{os} ads requires base" do
      let(:facts) { facts }
      let(:params) do
        {
          enabled_components: [
            'ads',
          ],
        }
      end

      it { is_expected.to compile.with_all_deps.and_raise_error(%r{Component 'ads' requires 'base'!}) }
    end

    context "on #{os} ads requires base_extended" do
      let(:facts) { facts }
      let(:params) do
        {
          enabled_components: [
            'ads',
            'base',
          ],
        }
      end

      it { is_expected.to compile.with_all_deps.and_raise_error(%r{Component 'ads' requires 'base_extended'!}) }
    end

    context "on #{os} missing SID" do
      let(:facts) do
        facts.merge(
          page_size: 4096,
          memory: {
            system: {
              total_bytes: 7_930_249_216,
            },
            swap: {
              total_bytes: 4_294_901_760,
            },
          },
          mountpoints: {
            '/dev/shm' => {
              size_bytes: 3_961_782_272,
            },
          },
        )
      end

      let(:params) do
        {
          enabled_components: [
            'base',
          ],
        }
      end

      it { is_expected.to compile.with_all_deps.and_raise_error(%r{At least one SID must be specified!}) }
    end

    context "on #{os} full config" do
      let(:params) do
        {
          system_ids: ['EP0'],
          enabled_components: [
            'base',
            'base_extended',
            'experimental',
            'ads',
            'bo',
            'cloudconnector',
            'hana',
            'router',
          ],
          router_oss_realm: 'p:CN=sr.domain.tld, OU=0123456789, OU=SAProuter, O=SAP, C=DE',
          router_rules: [
            'P0,1  *  192.168.1.1  3200  password  # SID dispatcher',
            'P0,1  *  192.168.1.2  3200  password  # SID dispatcher',
          ],
          distro_text: 'Best distribution ever build version 7.2',
        }
      end
      let(:facts) do
        facts.merge(
          page_size: 4096,
          memory: {
            system: {
              total_bytes: 7_930_249_216,
            },
            swap: {
              total_bytes: 4_294_901_760,
            },
          },
          mountpoints: {
            '/dev/shm' => {
              size_bytes: 3_961_782_272,
            },
          },
        )
      end

      if facts[:operatingsystemmajrelease] == 7
        let(:facts) do
          facts.merge(
            os: {
              release: {
                major: '7',
              },
            },
          )
        end

      elsif facts[:operatingsystemmajrelease] == 6
        let(:facts) do
          facts.merge(
            os: {
              release: {
                major: '6',
              },
            },
          )
        end

      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('sap::params') }
      it { is_expected.to contain_class('sap::install') }
      it { is_expected.to contain_sap__install__package_set('common') }
      it { is_expected.to contain_sap__install__package_set('base') }
      it { is_expected.to contain_sap__install__package_set('base_extended') }
      it { is_expected.to contain_sap__install__package_set('experimental') }
      it { is_expected.to contain_sap__install__package_set('ads') }
      it { is_expected.to contain_sap__install__package_set('saprouter') }
      it { is_expected.to contain_class('sap::config') }
      it { is_expected.to contain_class('sap::config::common') }
      it { is_expected.to contain_class('sap::config::limits') }
      it { is_expected.to contain_class('sap::config::sysctl') }
      it { is_expected.to contain_class('sap::config::tmpfs') }
      it { is_expected.to contain_class('sap::config::router') }
      it { is_expected.to contain_class('sap::service') }
      it { is_expected.to contain_class('sap::service::router') }

      if facts[:operatingsystemmajrelease] == '7'
        it { is_expected.to contain_class('sap::service::cloudconnector') }
        it { is_expected.to contain_sap__install__package_set('bo') }
        it { is_expected.to contain_sap__install__package_set('cloudconnector') }
        it { is_expected.to contain_sap__install__package_set('hana') }
      end

      # Common packages
      it { is_expected.to contain_package('uuidd').with_ensure('present') }

      # SAP Base packages
      it { is_expected.to contain_package('compat-libstdc++-33').with_ensure('present') }
      it { is_expected.to contain_package('elfutils-libelf-devel').with_ensure('present') }
      it { is_expected.to contain_package('gcc-c++').with_ensure('present') }
      it { is_expected.to contain_package('glibc').with_ensure('present') }
      it { is_expected.to contain_package('glibc-devel').with_ensure('present') }
      it { is_expected.to contain_package('glibc-headers').with_ensure('present') }
      it { is_expected.to contain_package('libaio').with_ensure('present') }
      it { is_expected.to contain_package('libaio-devel').with_ensure('present') }
      it { is_expected.to contain_package('libstdc++').with_ensure('present') }
      it { is_expected.to contain_package('libstdc++-devel').with_ensure('present') }
      it { is_expected.to contain_package('tcsh').with_ensure('present') }
      it { is_expected.to contain_package('xorg-x11-utils').with_ensure('present') }

      # SAP Base extensions packages
      it { is_expected.to contain_package('expat').with_ensure('present') }
      it { is_expected.to contain_package('libgcc').with_ensure('present') }
      it { is_expected.to contain_package('libX11').with_ensure('present') }
      it { is_expected.to contain_package('libXau').with_ensure('present') }
      it { is_expected.to contain_package('libxcb').with_ensure('present') }
      it { is_expected.to contain_package('krb5-libs').with_ensure('present') }
      if facts[:architecture] == 'x86_64'
        it { is_expected.to contain_package('glibc.i686').with_ensure('present') }
        it { is_expected.to contain_package('glibc-devel.i686').with_ensure('present') }
        it { is_expected.to contain_package('libgcc.i686').with_ensure('present') }
        it { is_expected.to contain_package('libX11.i686').with_ensure('present') }
        it { is_expected.to contain_package('libXau.i686').with_ensure('present') }
        it { is_expected.to contain_package('libxcb.i686').with_ensure('present') }
      end

      # Experimental packages
      it { is_expected.to contain_package('sap-common').with_ensure('present') }
      it { is_expected.to contain_package('sap-toolbox').with_ensure('present') }
      it { is_expected.to contain_package('sap-sapcar').with_ensure('present') }

      # SAP ADS packages
      it { is_expected.to contain_package('autoconf').with_ensure('present') }
      it { is_expected.to contain_package('automake').with_ensure('present') }
      it { is_expected.to contain_package('transfig').with_ensure('present') }
      it { is_expected.to contain_package('cyrus-sasl-lib').with_ensure('present') }
      it { is_expected.to contain_package('fontconfig').with_ensure('present') }
      it { is_expected.to contain_package('freetype').with_ensure('present') }
      it { is_expected.to contain_package('keyutils-libs').with_ensure('present') }
      it { is_expected.to contain_package('libcom_err').with_ensure('present') }
      it { is_expected.to contain_package('libidn').with_ensure('present') }
      it { is_expected.to contain_package('libidn-devel').with_ensure('present') }
      it { is_expected.to contain_package('libselinux').with_ensure('present') }
      it { is_expected.to contain_package('nspr').with_ensure('present') }
      it { is_expected.to contain_package('nss').with_ensure('present') }
      it { is_expected.to contain_package('nss-softokn').with_ensure('present') }
      it { is_expected.to contain_package('nss-softokn-freebl').with_ensure('present') }
      it { is_expected.to contain_package('nss-util').with_ensure('present') }
      it { is_expected.to contain_package('openldap').with_ensure('present') }
      it { is_expected.to contain_package('zlib').with_ensure('present') }
      if facts[:architecture] == 'x86_64'
        it { is_expected.to contain_package('nss-softokn-freebl.i686').with_ensure('present') }
      end

      # These packages are only supported on RHEL 7
      if facts[:operatingsystemmajrelease] == '7'
        # SAP BO packges
        it { is_expected.to contain_package('libXcursor').with_ensure('present') }
        it { is_expected.to contain_package('libXext').with_ensure('present') }
        it { is_expected.to contain_package('libXfixes').with_ensure('present') }
        it { is_expected.to contain_package('libXrender').with_ensure('present') }
        if facts[:architecture] == 'x86_64'
          it { is_expected.to contain_package('compat-libstdc++-33.i686').with_ensure('present') }
          it { is_expected.to contain_package('libstdc++.i686').with_ensure('present') }
          it { is_expected.to contain_package('libXcursor.i686').with_ensure('present') }
          it { is_expected.to contain_package('libXext.i686').with_ensure('present') }
          it { is_expected.to contain_package('libXfixes.i686').with_ensure('present') }
          it { is_expected.to contain_package('libXrender.i686').with_ensure('present') }
        end

        # SAP Cloud connector packages
        it { is_expected.to contain_package('sapjvm_8').with_ensure('present') }
        it { is_expected.to contain_package('com.sap.scc-ui').with_ensure('present') }

        # SAP HANA packages
        it { is_expected.to contain_package('PackageKit-gtk3-module').with_ensure('present') }
        it { is_expected.to contain_package('bind-utils').with_ensure('present') }
        it { is_expected.to contain_package('cairo').with_ensure('present') }
        it { is_expected.to contain_package('expect').with_ensure('present') }
        it { is_expected.to contain_package('graphviz').with_ensure('present') }
        it { is_expected.to contain_package('gtk2').with_ensure('present') }
        it { is_expected.to contain_package('iptraf-ng').with_ensure('present') }
        it { is_expected.to contain_package('java-1.8.0-openjdk').with_ensure('present') }
        it { is_expected.to contain_package('krb5-workstation').with_ensure('present') }
        it { is_expected.to contain_package('libcanberra-gtk2').with_ensure('present') }
        it { is_expected.to contain_package('libicu').with_ensure('present') }
        it { is_expected.to contain_package('libpng12').with_ensure('present') }
        it { is_expected.to contain_package('libssh2').with_ensure('present') }
        it { is_expected.to contain_package('libtool-ltdl').with_ensure('present') }
        it { is_expected.to contain_package('net-tools').with_ensure('present') }
        it { is_expected.to contain_package('numactl').with_ensure('present') }
        it { is_expected.to contain_package('openssl098e').with_ensure('present') }
        it { is_expected.to contain_package('openssl').with_ensure('present') }
        it { is_expected.to contain_package('xfsprogs').with_ensure('present') }
        it { is_expected.to contain_package('xulrunner').with_ensure('present') }

        # SAP cloudconnector service
        it { is_expected.to contain_service('scc_daemon').with('ensure' => 'running', 'enable' => 'true') }
      end

      # SAP router package
      it { is_expected.to contain_package('sap-router').with_ensure('present') }

      # SAP Linux configuration
      if facts[:operatingsystemmajrelease] == '7'
        # Test that the sap sysctl config file is created & the refresh is defined
        it {
          is_expected.to contain_file('/etc/sysctl.d/00-sap-base.conf').with(
            ensure: 'file',
            notify: 'Exec[sysctl-reload]',
          )

          is_expected.to contain_exec('/sbin/sysctl --system').with(
            refreshonly: true,
            alias: 'sysctl-reload',
          )
        }

        # Ensure the contents of the file match our expectations
        it 'is expected to contain valid SAP sysctl entries in /etc/sysctl.d/00-sap-base.conf' do
          content = catalogue.resource('file', '/etc/sysctl.d/00-sap-base.conf').send(:parameters)[:content]
          expect(content).to match(%r{\nkernel[.]sem = 1250 256000 100 8192\n})
          expect(content).to match(%r{\nvm[.]max_map_count = 2000000\n})
        end

        # Ensure limits is configured
        it { is_expected.to contain_file('/etc/security/limits.d/00-sap-base.conf').with_ensure('file') }

        it 'is expected to contain valid limits for the core applicaiton in /etc/security/limits.d/00-sap-base.conf' do
          content = catalogue.resource('file', '/etc/security/limits.d/00-sap-base.conf').send(:parameters)[:content]
          expect(content).to match(%r{\n@sapsys    hard    nofile    65536\n})
          expect(content).to match(%r{\n@sapsys    soft    nofile    65536\n})
          expect(content).to match(%r{\n@sapsys    soft    nproc    unlimited\n})
          expect(content).to match(%r{\n@sdba    hard    nofile    32800\n})
          expect(content).to match(%r{\n@sdba    soft    nofile    32800\n})
          expect(content).to match(%r{\n@dba    hard    nofile    32800\n})
          expect(content).to match(%r{\n@dba    soft    nofile    32800\n})
        end
      end

      # SAP router configuration
      it { is_expected.to contain_file('/etc/sysconfig/sap-router').with_ensure('file') }
      it 'is expected to generate valid content for sap-router' do
        content = catalogue.resource('file', '/etc/sysconfig/sap-router').send(:parameters)[:content]
        expect(content).to match('p:CN=sr.domain.tld, OU=0123456789, OU=SAProuter, O=SAP, C=DE')
      end
      it { is_expected.to contain_file('/opt/sap/R99/profile/saproutetab').with_ensure('file') }
      it 'is expected to generate valid content for saproutetab' do
        content = catalogue.resource('file', '/opt/sap/R99/profile/saproutetab').send(:parameters)[:content]
        expect(content).to match('P0,1  \*  192.168.1.1  3200  password  # SID dispatcher')
        expect(content).to match('P0,1  \*  192.168.1.2  3200  password  # SID dispatcher')
        expect(content).to match('D  \*  \*  \*  # If nothing match, traffic is denied')
      end

      # General UUID service
      it { is_expected.to contain_service('uuidd.socket').with('ensure' => 'running', 'enable' => 'true') }

      # SAP router service
      it { is_expected.to contain_service('sap-router').with('ensure' => 'running', 'enable' => 'true') }

      it { is_expected.to contain_file('/etc/redhat-release').with_ensure('file') }
      it 'must generate valid content for redhat-release' do
        content = catalogue.resource('file', '/etc/redhat-release').send(:parameters)[:content]
        expect(content).to match('Best distribution ever build version 7.2')
      end

      # Ensure tmpfs configuration is correct
      it {
        is_expected.to contain_file_line('fstab_tmpfs_size').with(
          ensure: 'present',
          path: '/etc/fstab',
          line: "tmpfs\t/dev/shm\ttmpfs\tsize=9g\t0 0",
        )

        is_expected.to contain_exec('remount_devshm').with(
          command: '/bin/mount -o remount /dev/shm',
          subscribe: 'File_line[fstab_tmpfs_size]',
          refreshonly: true,
        )
      }

      # Check for notify about swap space being too small
      it { is_expected.to contain_notify('SAP: Swap space may be undersized! Current 4 GiB, Target 16 GiB') }

      case facts[:operatingsystem]
      when 'RedHat'
        case facts[:operatingsystemmajrelease]
        when '6'
          it { is_expected.to contain_package('compat-gcc-34').with_ensure('present') }
          it { is_expected.to contain_package('pdksh').with_ensure('present') }
        end
      when 'CentOS'
        case facts[:operatingsystemmajrelease]
        when '6'
          it { is_expected.to contain_package('compat-gcc-34').with_ensure('present') }
          it { is_expected.to contain_package('pdksh').with_ensure('present') }
        end
      when 'Scientific'
        case facts[:operatingsystemmajrelease]
        when '6'
          it { is_expected.to contain_package('compat-gcc-34').with_ensure('present') }
          it { is_expected.to contain_package('pdksh').with_ensure('present') }
        end
      when 'OracleLinux'
        case facts[:operatingsystemmajrelease]
        when '6'
          it { is_expected.to contain_package('compat-gcc-34').with_ensure('present') }
          it { is_expected.to contain_package('pdksh').with_ensure('present') }
        end
      else
        it { is_expected.to contain_warning('The current operating system is not supported!') }
      end
    end

    context "on #{os} base mountpoints" do
      let(:facts) do
        facts.merge(
          page_size: 4096,
          memory: {
            system: {
              total_bytes: 7_930_249_216,
            },
            swap: {
              total_bytes: 4_294_901_760,
            },
          },
          mountpoints: {
            '/dev/shm' => {
              size_bytes: 3_961_782_272,
            },
          },
        )
      end
      let(:params) do
        {
          enabled_components: [
            'base',
          ],
          system_ids: [
            'EP0',
            'WP0',
          ],
          create_mount_points: true,
        }
      end

      # Ensure we included the mountpoint class
      it {
        is_expected.to contain_class('sap::config')
        is_expected.to contain_class('sap::config::mount_points')
      }

      # Ensure the common directories exist
      it {
        is_expected.to contain_sap__config__mount_point('/sapmnt')
        is_expected.to contain_file('/sapmnt').with(
          ensure: 'directory',
          owner: 'root',
          group: 'sapsys',
          mode: '0755',
        )

        is_expected.to contain_file('/sapmnt/EP0').with(
          ensure: 'directory',
          owner: 'ep0adm',
          group: 'sapsys',
          mode: '0755',
        ).that_requires('File[/sapmnt]')

        is_expected.to contain_file('/sapmnt/WP0').with(
          ensure: 'directory',
          owner: 'wp0adm',
          group: 'sapsys',
          mode: '0755',
        ).that_requires('File[/sapmnt]')
      }

      # Ensure that the base shared instance directories exist
      it {
        is_expected.to contain_file('/usr/sap').with(
          ensure: 'directory',
          owner: 'root',
          group: 'sapsys',
          mode: '0755',
        )

        is_expected.to contain_file('/usr/sap/trans').with(
          ensure: 'directory',
          owner: 'root',
          group: 'sapsys',
          mode: '0755',
        ).that_requires('File[/usr/sap]')
      }

      # Ensure the instance specific directories exist
      it {
        is_expected.to contain_file('/usr/sap/EP0').with(
          ensure: 'directory',
          owner: 'ep0adm',
          group: 'sapsys',
          mode: '0755',
        ).that_requires('File[/usr/sap]')

        is_expected.to contain_file('/usr/sap/WP0').with(
          ensure: 'directory',
          owner: 'wp0adm',
          group: 'sapsys',
          mode: '0755',
        ).that_requires('File[/usr/sap]')
      }
    end
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
    context "on #{os} nfsv4 sapmnt with nfs management" do
      let(:facts) do
        facts.merge(
          page_size: 4096,
          memory: {
            system: {
              total_bytes: 7_930_249_216,
            },
            swap: {
              total_bytes: 4_294_901_760,
            },
          },
          mountpoints: {
            '/dev/shm' => {
              size_bytes: 3_961_782_272,
            },
          },
        )
      end
      let(:params) do
        {
          enabled_components: [
            'base',
          ],
          system_ids: [
            'EP0',
            'WP0',
          ],
          create_mount_points: true,
          manage_mount_dependencies: true,
          mount_points: {
            common: {
              '/sapmnt' => {
                per_sid: false,
                file_params: {
                  owner: 'root',
                  group: 'sapsys',
                  mode: '0755',
                },
              },
              '/sapmnt/_SID_' => {
                per_sid: true,
                file_params: {
                  owner: '_sid_adm',
                  group: 'sapsys',
                  mode: '0755',
                },
                mount_params: {
                  managed: true,
                  type: 'nfsv4',
                  server: 'nfs.puppet.sap',
                  share: '/srv/nfs/sapmnt/_SID_',
                },
                required_files: [
                  '/sapmnt',
                ],
              },
            },
            base: {
              '/usr/sap' => {
                per_sid: false,
                file_params: {
                  owner: 'root',
                  group: 'sapsys',
                  mode: '0755',
                },
              },
              '/usr/sap/trans' => {
                per_sid: false,
                file_params: {
                  owner: 'root',
                  group: 'sapsys',
                  mode: '0755',
                },
                mount_params: {
                  managed: true,
                  type: 'nfsv4',
                  server: 'nfs.puppet.sap',
                  share: '/srv/nfs/trans',
                },
                required_files: [
                  '/usr/sap',
                ],
              },
              '/usr/sap/_SID_' => {
                per_sid: true,
                file_params: {
                  owner: '_sid_adm',
                  group: 'sapsys',
                  mode: '0755',
                },
                mount_params: {
                  managed: false,
                },
                required_files: [
                  '/usr/sap',
                ],
              },
            },
          },
        }
      end

      # Ensure it compiles
      it { is_expected.to compile.with_all_deps }

      # Ensure the mount dependency class is included
      it { is_expected.to contain_class('sap::install::mount_dependencies') }

      # Project the expected file & resource counts
      it {
        is_expected.to have_sap__config__mount_point_resource_count(7)
        is_expected.to have_nfs__client__mount_resource_count(3)
      }

      # Verify the actual directories
      it {
        is_expected.to contain_sap__config__mount_point('/sapmnt')
        is_expected.to contain_sap__config__mount_point('/sapmnt/_SID__EP0')
        is_expected.to contain_sap__config__mount_point('/sapmnt/_SID__WP0')

        is_expected.to contain_file('/sapmnt').with(
          ensure: 'directory',
          owner: 'root',
          group: 'sapsys',
          mode: '0755',
        )

        is_expected.to contain_nfs__client__mount('/sapmnt/EP0').with(
          ensure: 'mounted',
          server: 'nfs.puppet.sap',
          share: '/srv/nfs/sapmnt/EP0',
          atboot: true,
          options_nfsv4: 'rw,soft,noac,timeo=200,retrans=3,proto=tcp',
          owner: 'ep0adm',
          group: 'sapsys',
          mode: '0755',
        ).that_requires('File[/sapmnt]')

        is_expected.to contain_nfs__client__mount('/sapmnt/WP0').with(
          ensure: 'mounted',
          server: 'nfs.puppet.sap',
          share: '/srv/nfs/sapmnt/WP0',
          atboot: true,
          options_nfsv4: 'rw,soft,noac,timeo=200,retrans=3,proto=tcp',
          owner: 'wp0adm',
          group: 'sapsys',
          mode: '0755',
        ).that_requires('File[/sapmnt]')
      }

      # Ensure that the base shared instance directories exist
      it {
        is_expected.to contain_sap__config__mount_point('/usr/sap')
        is_expected.to contain_sap__config__mount_point('/usr/sap/trans')

        is_expected.to contain_file('/usr/sap').with(
          ensure: 'directory',
          owner: 'root',
          group: 'sapsys',
          mode: '0755',
        )

        is_expected.to contain_nfs__client__mount('/usr/sap/trans').with(
          ensure: 'mounted',
          server: 'nfs.puppet.sap',
          share: '/srv/nfs/trans',
          atboot: true,
          options_nfsv4: 'rw,soft,noac,timeo=200,retrans=3,proto=tcp',
          owner: 'root',
          group: 'sapsys',
          mode: '0755',
        ).that_requires('File[/usr/sap]')
      }

      # Ensure the instance specific directories exist
      it {
        is_expected.to contain_sap__config__mount_point('/usr/sap/_SID__EP0')
        is_expected.to contain_sap__config__mount_point('/usr/sap/_SID__WP0')

        is_expected.to contain_file('/usr/sap/EP0').with(
          ensure: 'directory',
          owner: 'ep0adm',
          group: 'sapsys',
          mode: '0755',
        ).that_requires('File[/usr/sap]')

        is_expected.to contain_file('/usr/sap/WP0').with(
          ensure: 'directory',
          owner: 'wp0adm',
          group: 'sapsys',
          mode: '0755',
        ).that_requires('File[/usr/sap]')
      }
    end
  end

  on_supported_os(test_on).each do |os, facts|
    context "on #{os} db2 without mountpoints" do
      let(:facts) do
        facts.merge(
          page_size: 4_096,
          memory: {
            system: {
              total_bytes: 7_930_249_216,
            },
            swap: {
              total_bytes: 4_294_901_760,
            },
          },
        )
      end

      let(:params) do
        {
          system_ids: ['EP0', 'EP1'],
          enabled_components: [
            'db2',
          ],
          create_mount_points: false,
        }
      end

      it { is_expected.to compile.with_all_deps }

      # Check the sysctl file
      it { is_expected.to contain_file('/etc/sysctl.d/00-sap-db2.conf') }

      # Ensure the contents of the sysctl file match our expectations
      it 'is expected to contain valid db2 sysctl entries in /etc/sysctl.d/00-sap-db2.conf' do
        content = catalogue.resource('file', '/etc/sysctl.d/00-sap-db2.conf').send(:parameters)[:content]
        expect(content).to match(%r{\nkernel[.]shmmni = 1890\n})
        expect(content).to match(%r{\nkernel[.]shmmax = 7930249216\n})
        expect(content).to match(%r{\nkernel[.]shmall = 3872192\n})
        expect(content).to match(%r{\nkernel[.]sem = 250 256000 32 1890\n})
        expect(content).to match(%r{\nkernel[.]msgmni = 7562\n})
        expect(content).to match(%r{\nkernel[.]msgmax = 65536\n})
        expect(content).to match(%r{\nkernel[.]msgmnb = 65536\n})
        expect(content).to match(%r{\nvm[.]swappiness = 0\n})
        expect(content).to match(%r{\nvm[.]overcommit_memory = 0\n})
      end

      # Ensure we have the filter file
      it { is_expected.to contain_file('/etc/security/limits.d/00-sap-db2.conf') }

      it 'is expected to contain valid sid specific limits for the database in /etc/security/limits.d/00-sap-db2.conf' do
        content = catalogue.resource('file', '/etc/security/limits.d/00-sap-db2.conf').send(:parameters)[:content]
        expect(content).to match(%r{\n@dbep0adm    hard    data    unlimited\n})
        expect(content).to match(%r{\n@dbep0adm    soft    data    unlimited\n})
        expect(content).to match(%r{\n@dbep0adm    hard    nofile    65536\n})
        expect(content).to match(%r{\n@dbep0adm    soft    nofile    65536\n})
        expect(content).to match(%r{\n@dbep0adm    hard    fsize    unlimited\n})
        expect(content).to match(%r{\n@dbep0adm    soft    fsize    unlimited\n})
        expect(content).to match(%r{\n@dbep1adm    hard    data    unlimited\n})
        expect(content).to match(%r{\n@dbep1adm    soft    data    unlimited\n})
        expect(content).to match(%r{\n@dbep1adm    hard    nofile    65536\n})
        expect(content).to match(%r{\n@dbep1adm    soft    nofile    65536\n})
        expect(content).to match(%r{\n@dbep1adm    hard    fsize    unlimited\n})
        expect(content).to match(%r{\n@dbep1adm    soft    fsize    unlimited\n})
      end
    end

    context "on #{os} db2 missing per_sid value" do
      let(:facts) do
        facts.merge(
          page_size: 4_096,
          memory: {
            system: {
              total_bytes: 7_930_249_216,
            },
            swap: {
              total_bytes: 4_294_901_760,
            },
          },
        )
      end

      let(:params) do
        {
          system_ids: ['EP0'],
          enabled_components: [
            'db2',
          ],
          create_mount_points: true,
          mount_points: {
            db2: {
              '/db2/Missing/per_sid' => {
              },
            },
          },
        }
      end

      it { is_expected.to compile.with_all_deps.and_raise_error(%r{mount_point: 'db2' path '/db2/Missing/per_sid' missing 'per_sid'!}) }
    end

    context "on #{os} db2 missing file_params" do
      let(:facts) do
        facts.merge(
          page_size: 4_096,
          memory: {
            system: {
              total_bytes: 7_930_249_216,
            },
            swap: {
              total_bytes: 4_294_901_760,
            },
          },
        )
      end

      let(:params) do
        {
          system_ids: ['EP0'],
          enabled_components: [
            'db2',
          ],
          create_mount_points: true,
          mount_points: {
            db2: {
              '/db2/Missing/file_params' => {
                per_sid: false,
              },
            },
          },
        }
      end

      it { is_expected.to compile.with_all_deps.and_raise_error(%r{mount_point: 'db2' path '/db2/Missing/file_params' missing 'file_params'!}) }
    end

    context "on #{os} db2 SID specific but missing substitution" do
      let(:facts) do
        facts.merge(
          page_size: 4_096,
          memory: {
            system: {
              total_bytes: 7_930_249_216,
            },
            swap: {
              total_bytes: 4_294_901_760,
            },
          },
        )
      end

      let(:params) do
        {
          system_ids: ['EP0'],
          enabled_components: [
            'db2',
          ],
          create_mount_points: true,
          mount_points: {
            db2: {
              '/db2/Missing/pattern' => {
                per_sid: true,
                file_params: {
                  owner: 'db2_sid_',
                  group: 'db_sid_adm',
                  mode: '0755',
                },
              },
            },
          },
        }
      end

      it { is_expected.to compile.with_all_deps.and_raise_error(%r{mount_point: SID specified for '/db2/Missing/pattern' but does not contain '_sid_' or '_SID_'!}) }
    end

    context "on #{os} db2 count specified without pattern" do
      let(:facts) do
        facts.merge(
          page_size: 4_096,
          memory: {
            system: {
              total_bytes: 7_930_249_216,
            },
            swap: {
              total_bytes: 4_294_901_760,
            },
          },
        )
      end

      let(:params) do
        {
          system_ids: ['EP0'],
          enabled_components: [
            'db2',
          ],
          create_mount_points: true,
          mount_points: {
            db2: {
              '/db2/Missing/count_pattern' => {
                per_sid: true,
                count: 4,
                file_params: {
                  owner: 'db2_sid_',
                  group: 'db_sid_adm',
                  mode: '0755',
                },
              },
            },
          },
        }
      end

      it { is_expected.to compile.with_all_deps.and_raise_error(%r{mount_point: '/db2/Missing/count_pattern' specifies \$count but does not contain '_N_'!}) }
    end

    context "on #{os} db2 invalid count specified" do
      let(:facts) do
        facts.merge(
          page_size: 4_096,
          memory: {
            system: {
              total_bytes: 7_930_249_216,
            },
            swap: {
              total_bytes: 4_294_901_760,
            },
          },
        )
      end

      let(:params) do
        {
          system_ids: ['EP0'],
          enabled_components: [
            'db2',
          ],
          create_mount_points: true,
          mount_points: {
            db2: {
              '/db2/bad/count_N_' => {
                per_sid: true,
                count: 0,
                file_params: {
                  owner: 'db2_sid_',
                  group: 'db_sid_adm',
                  mode: '0755',
                },
              },
            },
          },
        }
      end

      it { is_expected.to compile.with_all_deps.and_raise_error(%r{mount_point: '/db2/bad/count_N_' specifies \$count not >= 1!}) }
    end

    context "on #{os} db2 valid directories" do
      let(:facts) do
        facts.merge(
          page_size: 4_096,
          memory: {
            system: {
              total_bytes: 7_930_249_216,
            },
            swap: {
              total_bytes: 4_294_901_760,
            },
          },
        )
      end

      let(:params) do
        {
          system_ids: ['EP0', 'EP1'],
          enabled_components: [
            'db2',
          ],
          create_mount_points: true,
        }
      end

      # Ensure we included the mountpoint class
      it {
        is_expected.to contain_class('sap::config')
        is_expected.to contain_class('sap::config::mount_points')
      }

      # Ensure DB2 packages are present
      it {
        is_expected.to contain_package('libaio').with_ensure('present')
        is_expected.to contain_package('ksh').with_ensure('present')
      }
      if facts[:architecture] == 'ppc64'
        it {
          is_expected.to contain_package('vacpp.rte').with_ensure('present')
        }
      end

      # Ensure the common directories exist
      it {
        is_expected.to contain_file('/sapmnt').with(
          ensure: 'directory',
          owner: 'root',
          group: 'sapsys',
          mode: '0755',
        )

        is_expected.to contain_file('/sapmnt/EP0').with(
          ensure: 'directory',
          owner: 'ep0adm',
          group: 'sapsys',
          mode: '0755',
        ).that_requires('File[/sapmnt]')

        is_expected.to contain_file('/sapmnt/EP1').with(
          ensure: 'directory',
          owner: 'ep1adm',
          group: 'sapsys',
          mode: '0755',
        ).that_requires('File[/sapmnt]')
      }

      # Ensure that the application server directories are absent
      it {
        is_expected.not_to contain_file('/usr/sap')
        is_expected.not_to contain_file('/usr/sap/EP0')
        is_expected.not_to contain_file('/usr/sap/EP1')
        is_expected.not_to contain_file('/usr/sap/trans')
      }

      # Ensure the DB2 directories are created for both EP0 and EP1
      it {
        # Base db2
        is_expected.to contain_file('/db2').with(
          ensure: 'directory',
          owner: 'root',
          group: 'root',
          mode: '0755',
        )

        # Home directories
        is_expected.to contain_file('/db2/db2ep0').with(
          ensure: 'directory',
          owner: 'db2ep0',
          group: 'dbep0adm',
          mode: '0755',
        ).that_requires('File[/db2]')
        is_expected.to contain_file('/db2/db2ep1').with(
          ensure: 'directory',
          owner: 'db2ep1',
          group: 'dbep1adm',
          mode: '0755',
        ).that_requires('File[/db2]')

        # SID directory
        is_expected.to contain_file('/db2/EP0').with(
          ensure: 'directory',
          owner: 'db2ep0',
          group: 'dbep0adm',
          mode: '0755',
        ).that_requires('File[/db2]')
        is_expected.to contain_file('/db2/EP1').with(
          ensure: 'directory',
          owner: 'db2ep1',
          group: 'dbep1adm',
          mode: '0755',
        ).that_requires('File[/db2]')

        # log directory
        is_expected.to contain_file('/db2/EP0/log_dir').with(
          ensure: 'directory',
          owner: 'db2ep0',
          group: 'dbep0adm',
          mode: '0755',
        ).that_requires('File[/db2/EP0]')
        is_expected.to contain_file('/db2/EP1/log_dir').with(
          ensure: 'directory',
          owner: 'db2ep1',
          group: 'dbep1adm',
          mode: '0755',
        ).that_requires('File[/db2/EP1]')

        # log archive directory
        is_expected.to contain_file('/db2/EP0/log_archive').with(
          ensure: 'directory',
          owner: 'db2ep0',
          group: 'dbep0adm',
          mode: '0755',
        ).that_requires('File[/db2/EP0]')
        is_expected.to contain_file('/db2/EP1/log_archive').with(
          ensure: 'directory',
          owner: 'db2ep1',
          group: 'dbep1adm',
          mode: '0755',
        ).that_requires('File[/db2/EP1]')

        # Dump Directory
        is_expected.to contain_file('/db2/EP0/db2dump').with(
          ensure: 'directory',
          owner: 'db2ep0',
          group: 'dbep0adm',
          mode: '0755',
        ).that_requires('File[/db2/EP0]')
        is_expected.to contain_file('/db2/EP1/db2dump').with(
          ensure: 'directory',
          owner: 'db2ep1',
          group: 'dbep1adm',
          mode: '0755',
        ).that_requires('File[/db2/EP1]')

        # Data Directories
        is_expected.to contain_file('/db2/EP0/sapdata1').with(
          ensure: 'directory',
          owner: 'db2ep0',
          group: 'dbep0adm',
          mode: '0750',
        ).that_requires('File[/db2/EP0]')
        is_expected.to contain_file('/db2/EP1/sapdata1').with(
          ensure: 'directory',
          owner: 'db2ep1',
          group: 'dbep1adm',
          mode: '0750',
        ).that_requires('File[/db2/EP1]')

        is_expected.to contain_file('/db2/EP0/sapdata2').with(
          ensure: 'directory',
          owner: 'db2ep0',
          group: 'dbep0adm',
          mode: '0750',
        ).that_requires('File[/db2/EP0]')
        is_expected.to contain_file('/db2/EP1/sapdata2').with(
          ensure: 'directory',
          owner: 'db2ep1',
          group: 'dbep1adm',
          mode: '0750',
        ).that_requires('File[/db2/EP1]')

        is_expected.to contain_file('/db2/EP0/sapdata3').with(
          ensure: 'directory',
          owner: 'db2ep0',
          group: 'dbep0adm',
          mode: '0750',
        ).that_requires('File[/db2/EP0]')
        is_expected.to contain_file('/db2/EP1/sapdata3').with(
          ensure: 'directory',
          owner: 'db2ep1',
          group: 'dbep1adm',
          mode: '0750',
        ).that_requires('File[/db2/EP1]')

        is_expected.to contain_file('/db2/EP0/sapdata4').with(
          ensure: 'directory',
          owner: 'db2ep0',
          group: 'dbep0adm',
          mode: '0750',
        ).that_requires('File[/db2/EP0]')
        is_expected.to contain_file('/db2/EP1/sapdata4').with(
          ensure: 'directory',
          owner: 'db2ep1',
          group: 'dbep1adm',
          mode: '0750',
        ).that_requires('File[/db2/EP1]')
      }
    end
  end
end
