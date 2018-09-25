require 'spec_helper'

describe 'sap::sysctl_line' do
  context 'missing calc type' do
    it { 
      is_expected.to run.with_params(
        'kernel.shmall',
        {
          'value' => 'test'
        }
      ).and_raise_error(
        Puppet::ParseError,
        %r{sap::sysctl_line: \'kernel.shmall\' missing \'calc_type\' entry!},
      )
    }
  end

  context 'invalid calc type' do
    it { 
      is_expected.to run.with_params(
        'kernel.shmall',
        {
          'calc_type' => 'quadruple',
          'value' => 'test'
        }
      ).and_raise_error(
        Puppet::ParseError,
        %r{sap::sysctl_line: \'kernel.shmall\' invalid \'calc_type\' \'quadruple\'!},
      )
    }
  end

  context 'missing compound content' do
    it { 
      is_expected.to run.with_params(
        'kernel.sem',
        {
          'calc_type' => 'compound',
        }
      ).and_raise_error(
        Puppet::ParseError,
        %r{sap::sysctl_line: \'kernel.sem\' \'compound\' calc_type must specify \'content\'!},
      )
    }
  end

  context 'simple single value' do
    it {
      is_expected.to run.with_params(
        'kernel.shmall',
        {
          'calc_type' => 'value',
          'value' => 32,
        },
      ).and_return('kernel.shmall = 32')
    }
  end

  context 'simple single calculated' do
    it {
      is_expected.to run.with_params(
        'kernel.msgmni',
        {
          'calc_type' => 'calculated',
          'base' => 8589934592,
          'multiplier' => 1024,
          'divisor' => 1073741824
        },
      ).and_return('kernel.msgmni = 8192')
    }
  end

  context 'compound content calculation' do
    it { 
      is_expected.to run.with_params(
        'kernel.sem',
        {
          'calc_type' => 'compound',
          'content' => [
            {
              'calc_type' => 'value',
              'value' => '250'
            },
            {
              'calc_type' => 'value',
              'value' => '256000'
            },
            {
              'calc_type' => 'value',
              'value' => '32'
            },
            {
              'calc_type' => 'calculated',
              'base' => 8589934592,
              'multiplier' => 256,
              'divisor' => 1073741824
            },
          ],
        }
      ).and_return('kernel.sem = 250 256000 32 2048')
    }
  end
end
