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
  end
end
