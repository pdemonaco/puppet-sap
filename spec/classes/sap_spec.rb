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
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          page_size: 4096,
          memory: {
            system: {
              total_bytes: 7_930_249_216,
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
      it { is_expected.to contain_package('uuidd').with_ensure('installed') }

      # SAP Base packages
      it { is_expected.to contain_package('compat-libstdc++-33').with_ensure('installed') }
      it { is_expected.to contain_package('elfutils-libelf-devel').with_ensure('installed') }
      it { is_expected.to contain_package('gcc-c++').with_ensure('installed') }
      it { is_expected.to contain_package('glibc').with_ensure('installed') }
      it { is_expected.to contain_package('glibc-devel').with_ensure('installed') }
      it { is_expected.to contain_package('glibc-headers').with_ensure('installed') }
      it { is_expected.to contain_package('libaio').with_ensure('installed') }
      it { is_expected.to contain_package('libaio-devel').with_ensure('installed') }
      it { is_expected.to contain_package('libstdc++').with_ensure('installed') }
      it { is_expected.to contain_package('libstdc++-devel').with_ensure('installed') }
      it { is_expected.to contain_package('tcsh').with_ensure('installed') }
      it { is_expected.to contain_package('xorg-x11-utils').with_ensure('installed') }

      # SAP Base extensions packages
      it { is_expected.to contain_package('expat').with_ensure('installed') }
      it { is_expected.to contain_package('libgcc').with_ensure('installed') }
      it { is_expected.to contain_package('libX11').with_ensure('installed') }
      it { is_expected.to contain_package('libXau').with_ensure('installed') }
      it { is_expected.to contain_package('libxcb').with_ensure('installed') }
      it { is_expected.to contain_package('krb5-libs').with_ensure('installed') }
      if facts[:architecture] == 'x86_64'
        it { is_expected.to contain_package('glibc.i686').with_ensure('installed') }
        it { is_expected.to contain_package('glibc-devel.i686').with_ensure('installed') }
        it { is_expected.to contain_package('libgcc.i686').with_ensure('installed') }
        it { is_expected.to contain_package('libX11.i686').with_ensure('installed') }
        it { is_expected.to contain_package('libXau.i686').with_ensure('installed') }
        it { is_expected.to contain_package('libxcb.i686').with_ensure('installed') }
      end

      # Experimental packages
      it { is_expected.to contain_package('sap-common').with_ensure('installed') }
      it { is_expected.to contain_package('sap-toolbox').with_ensure('installed') }
      it { is_expected.to contain_package('sap-sapcar').with_ensure('installed') }

      # SAP ADS packages
      it { is_expected.to contain_package('autoconf').with_ensure('installed') }
      it { is_expected.to contain_package('automake').with_ensure('installed') }
      it { is_expected.to contain_package('transfig').with_ensure('installed') }
      it { is_expected.to contain_package('cyrus-sasl-lib').with_ensure('installed') }
      it { is_expected.to contain_package('fontconfig').with_ensure('installed') }
      it { is_expected.to contain_package('freetype').with_ensure('installed') }
      it { is_expected.to contain_package('keyutils-libs').with_ensure('installed') }
      it { is_expected.to contain_package('libcom_err').with_ensure('installed') }
      it { is_expected.to contain_package('libidn').with_ensure('installed') }
      it { is_expected.to contain_package('libidn-devel').with_ensure('installed') }
      it { is_expected.to contain_package('libselinux').with_ensure('installed') }
      it { is_expected.to contain_package('nspr').with_ensure('installed') }
      it { is_expected.to contain_package('nss').with_ensure('installed') }
      it { is_expected.to contain_package('nss-softokn').with_ensure('installed') }
      it { is_expected.to contain_package('nss-softokn-freebl').with_ensure('installed') }
      it { is_expected.to contain_package('nss-util').with_ensure('installed') }
      it { is_expected.to contain_package('openldap').with_ensure('installed') }
      it { is_expected.to contain_package('zlib').with_ensure('installed') }
      if facts[:architecture] == 'x86_64'
        it { is_expected.to contain_package('nss-softokn-freebl.i686').with_ensure('installed') }
      end

      # These packages are only supported on RHEL 7
      if facts[:operatingsystemmajrelease] == '7'
        # SAP BO packges
        it { is_expected.to contain_package('libXcursor').with_ensure('installed') }
        it { is_expected.to contain_package('libXext').with_ensure('installed') }
        it { is_expected.to contain_package('libXfixes').with_ensure('installed') }
        it { is_expected.to contain_package('libXrender').with_ensure('installed') }
        if facts[:architecture] == 'x86_64'
          it { is_expected.to contain_package('compat-libstdc++-33.i686').with_ensure('installed') }
          it { is_expected.to contain_package('libstdc++.i686').with_ensure('installed') }
          it { is_expected.to contain_package('libXcursor.i686').with_ensure('installed') }
          it { is_expected.to contain_package('libXext.i686').with_ensure('installed') }
          it { is_expected.to contain_package('libXfixes.i686').with_ensure('installed') }
          it { is_expected.to contain_package('libXrender.i686').with_ensure('installed') }
        end

        # SAP Cloud connector packages
        it { is_expected.to contain_package('sapjvm_8').with_ensure('installed') }
        it { is_expected.to contain_package('com.sap.scc-ui').with_ensure('installed') }

        # SAP HANA packages
        it { is_expected.to contain_package('PackageKit-gtk3-module').with_ensure('installed') }
        it { is_expected.to contain_package('bind-utils').with_ensure('installed') }
        it { is_expected.to contain_package('cairo').with_ensure('installed') }
        it { is_expected.to contain_package('expect').with_ensure('installed') }
        it { is_expected.to contain_package('graphviz').with_ensure('installed') }
        it { is_expected.to contain_package('gtk2').with_ensure('installed') }
        it { is_expected.to contain_package('iptraf-ng').with_ensure('installed') }
        it { is_expected.to contain_package('java-1.8.0-openjdk').with_ensure('installed') }
        it { is_expected.to contain_package('krb5-workstation').with_ensure('installed') }
        it { is_expected.to contain_package('libcanberra-gtk2').with_ensure('installed') }
        it { is_expected.to contain_package('libicu').with_ensure('installed') }
        it { is_expected.to contain_package('libpng12').with_ensure('installed') }
        it { is_expected.to contain_package('libssh2').with_ensure('installed') }
        it { is_expected.to contain_package('libtool-ltdl').with_ensure('installed') }
        it { is_expected.to contain_package('net-tools').with_ensure('installed') }
        it { is_expected.to contain_package('numactl').with_ensure('installed') }
        it { is_expected.to contain_package('openssl098e').with_ensure('installed') }
        it { is_expected.to contain_package('openssl').with_ensure('installed') }
        it { is_expected.to contain_package('xfsprogs').with_ensure('installed') }
        it { is_expected.to contain_package('xulrunner').with_ensure('installed') }

        # SAP cloudconnector service
        it { is_expected.to contain_service('scc_daemon').with('ensure' => 'running', 'enable' => 'true') }
      end

      # SAP router package
      it { is_expected.to contain_package('sap-router').with_ensure('installed') }

      # SAP Linux configuration
      if facts[:operatingsystemmajrelease] == '7'
        # Test that the sap config file is created & the refresh is defined
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
      it { is_expected.to contain_service('uuidd').with('ensure' => 'running', 'enable' => 'true') }

      # SAP router service
      it { is_expected.to contain_service('sap-router').with('ensure' => 'running', 'enable' => 'true') }

      it { is_expected.to contain_file('/etc/redhat-release').with_ensure('file') }
      it 'must generate valid content for redhat-release' do
        content = catalogue.resource('file', '/etc/redhat-release').send(:parameters)[:content]
        expect(content).to match('Best distribution ever build version 7.2')
      end

      case facts[:operatingsystem]
      when 'RedHat'
        case facts[:operatingsystemmajrelease]
        when '6'
          it { is_expected.to contain_package('compat-gcc-34').with_ensure('installed') }
          it { is_expected.to contain_package('pdksh').with_ensure('installed') }
        end
      when 'CentOS'
        case facts[:operatingsystemmajrelease]
        when '6'
          it { is_expected.to contain_package('compat-gcc-34').with_ensure('installed') }
          it { is_expected.to contain_package('pdksh').with_ensure('installed') }
        end
      when 'Scientific'
        case facts[:operatingsystemmajrelease]
        when '6'
          it { is_expected.to contain_package('compat-gcc-34').with_ensure('installed') }
          it { is_expected.to contain_package('pdksh').with_ensure('installed') }
        end
      when 'OracleLinux'
        case facts[:operatingsystemmajrelease]
        when '6'
          it { is_expected.to contain_package('compat-gcc-34').with_ensure('installed') }
          it { is_expected.to contain_package('pdksh').with_ensure('installed') }
        end
      else
        it { is_expected.to contain_warning('The current operating system is not supported!') }
      end
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
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          page_size: 4_096,
          memory: {
            system: {
              total_bytes: 7_930_249_216,
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
        expect(content).to match(%r{\n@db2ep0adm    hard    data    unlimited\n})
        expect(content).to match(%r{\n@db2ep0adm    soft    data    unlimited\n})
        expect(content).to match(%r{\n@db2ep0adm    hard    nofile    65536\n})
        expect(content).to match(%r{\n@db2ep0adm    soft    nofile    65536\n})
        expect(content).to match(%r{\n@db2ep0adm    hard    fsize    unlimited\n})
        expect(content).to match(%r{\n@db2ep0adm    soft    fsize    unlimited\n})
        expect(content).to match(%r{\n@db2ep1adm    hard    data    unlimited\n})
        expect(content).to match(%r{\n@db2ep1adm    soft    data    unlimited\n})
        expect(content).to match(%r{\n@db2ep1adm    hard    nofile    65536\n})
        expect(content).to match(%r{\n@db2ep1adm    soft    nofile    65536\n})
        expect(content).to match(%r{\n@db2ep1adm    hard    fsize    unlimited\n})
        expect(content).to match(%r{\n@db2ep1adm    soft    fsize    unlimited\n})
      end
    end
  end
end
