require 'spec_helper'

describe 'sap::cluster::prepare', type: :class do
  let :facts do
    {
      os: {
        family: 'RedHat',
        release: {
          major: 7,
        },
      },
    }
  end

  context 'db2 cleanup environment files' do
    before(:each) do
      facts.merge!(
        sap: {
          sid_hash: {
            PRD: {
              instances: {
                database: {
                  type: 'db2',
                },
              },
            },
          },
        },
      )
    end
    let(:node) { 'prd-a-dba.example.org' }

    it 'manages the appropriate number of environment files' do
      is_expected.to have_file_resource_count(12)
    end

    it 'removes all hostname specific files from the db2 home' do
      is_expected.to contain_file('/db2/db2prd/.dbenv_prd-a-dba.sh').with_ensure('absent')
      is_expected.to contain_file('/db2/db2prd/.dbenv_prd-a-dba.csh').with_ensure('absent')
      is_expected.to contain_file('/db2/db2prd/.sapenv_prd-a-dba.sh').with_ensure('absent')
      is_expected.to contain_file('/db2/db2prd/.sapenv_prd-a-dba.csh').with_ensure('absent')
    end

    it 'removes all hostname specific files the sidadm home' do
      is_expected.to contain_file('/home/prdadm/.sapsrc_prd-a-dba.sh').with_ensure('absent')
      is_expected.to contain_file('/home/prdadm/.sapsrc_prd-a-dba.csh').with_ensure('absent')
      is_expected.to contain_file('/home/prdadm/.sapenv_prd-a-dba.sh').with_ensure('absent')
      is_expected.to contain_file('/home/prdadm/.sapenv_prd-a-dba.csh').with_ensure('absent')
      is_expected.to contain_file('/home/prdadm/.j2eeenv_prd-a-dba.sh').with_ensure('absent')
      is_expected.to contain_file('/home/prdadm/.j2eeenv_prd-a-dba.csh').with_ensure('absent')
      is_expected.to contain_file('/home/prdadm/.dbenv_prd-a-dba.sh').with_ensure('absent')
      is_expected.to contain_file('/home/prdadm/.dbenv_prd-a-dba.csh').with_ensure('absent')
    end

    it 'installs the cluster packages' do
      is_expected.to contain_package('resource-agents').with_ensure('present')
      is_expected.to contain_package('resource-agents-sap').with_ensure('present')
    end
  end

  context 'parse instance data for ASCS and ERS' do
    before(:each) do
      facts.merge!(
        sap: {
          sid_hash: {
            PRD: {
              instances: {
                '01' => {
                  type: 'ASCS',
                  profiles: [
                    '/sapmnt/PRD/profile/PRD_ASCS01_prd-a-cs',
                    '/sapmnt/PRD/profile/START_ASCS01_prd-a-cs',
                  ],
                },
                '02' => {
                  type: 'ERS',
                  profiles: [
                    '/sapmnt/PRD/profile/PRD_ERS02_prd-a-ers',
                    '/sapmnt/PRD/profile/START_ERS02_prd-a-ers',
                  ],
                },
                '00' => {
                  type: 'D',
                  profiles: [
                    '/sapmnt/PRD/profile/PRD_D00_prd-a-app00',
                    '/sapmnt/PRD/profile/START_D00_prd-a-app00',
                  ],
                },
              },
            },
          },
        },
      )
    end

    it 'manages the appropriate number of environment files' do
      is_expected.to have_file_resource_count(8)
    end

    it 'modifies the correct number of profiles' do
      is_expected.to have_exec_resource_count(4)
    end

    it "attempts to replace 'Restart' with 'Start' for SCS and ERS profiles" do
      is_expected.to contain_exec("sed -i 's/^Restart_Program/Start_Program/' /sapmnt/PRD/profile/PRD_ASCS01_prd-a-cs").with(
        path: '/sbin:/bin:/usr/sbin:/usr/bin',
        onlyif: [
          'test -f /sapmnt/PRD/profile/PRD_ASCS01_prd-a-cs',
          'test 0 -eq $(grep "^Restart_Program" /sapmnt/PRD/profile/PRD_ASCS01_prd-a-cs >/dev/null; echo $?)',
        ],
      )
      is_expected.to contain_exec("sed -i 's/^Restart_Program/Start_Program/' /sapmnt/PRD/profile/START_ASCS01_prd-a-cs").with(
        path: '/sbin:/bin:/usr/sbin:/usr/bin',
        onlyif: [
          'test -f /sapmnt/PRD/profile/START_ASCS01_prd-a-cs',
          'test 0 -eq $(grep "^Restart_Program" /sapmnt/PRD/profile/START_ASCS01_prd-a-cs >/dev/null; echo $?)',
        ],
      )
      is_expected.to contain_exec("sed -i 's/^Restart_Program/Start_Program/' /sapmnt/PRD/profile/PRD_ERS02_prd-a-ers").with(
        path: '/sbin:/bin:/usr/sbin:/usr/bin',
        onlyif: [
          'test -f /sapmnt/PRD/profile/PRD_ERS02_prd-a-ers',
          'test 0 -eq $(grep "^Restart_Program" /sapmnt/PRD/profile/PRD_ERS02_prd-a-ers >/dev/null; echo $?)',
        ],
      )
      is_expected.to contain_exec("sed -i 's/^Restart_Program/Start_Program/' /sapmnt/PRD/profile/START_ERS02_prd-a-ers").with(
        path: '/sbin:/bin:/usr/sbin:/usr/bin',
        onlyif: [
          'test -f /sapmnt/PRD/profile/START_ERS02_prd-a-ers',
          'test 0 -eq $(grep "^Restart_Program" /sapmnt/PRD/profile/START_ERS02_prd-a-ers >/dev/null; echo $?)',
        ],
      )
    end

    it 'does not modify the D profiles' do
      is_expected.not_to contain_exec("sed -i 's/^Restart_Program/Start_Program/' /sapmnt/PRD/profile/PRD_D00_prd-a-app00")
      is_expected.not_to contain_exec("sed -i 's/^Restart_Program/Start_Program/' /sapmnt/PRD/profile/START_D00_prd-a-app00")
    end

    it 'installs the cluster packages' do
      is_expected.to contain_package('resource-agents').with_ensure('present')
      is_expected.to contain_package('resource-agents-sap').with_ensure('present')
    end
  end
end
