require 'spec_helper'

describe 'sap::sysctl_calculated_values' do

  context 'simple single value' do
    it {
      is_expected.to run.with_params(
        [
          {
            'calc_type' => 'value',
            'value' => 32,
          },
        ],
        0
      ).and_return(' 32')
    }
  end

  context 'missing calc type' do
    it { 
      is_expected.to run.with_params([{'value' => 'test'}], 0).and_raise_error(
        Puppet::ParseError,
        %r{sap::sysctl_calculated_value: a \'calc_type\' must be specified!},
      )
    }
  end

  context 'invalid calc_type' do
    it { 
      is_expected.to run.with_params(
        [
          {
            'calc_type' => 'double',
            'value' => 'test',
          }
        ],
        0
      ).and_raise_error(
        Puppet::ParseError,
        %r{sap::sysctl_calculated_value: Unknown \'calc_type\' \'double\'},
      )
    }
  end

  context 'calculation missing base' do
    it { 
      is_expected.to run.with_params(
        [
          {
            'calc_type' => 'calculated',
          }
        ],
        0
      ).and_raise_error(
        Puppet::ParseError,
        %r{sap::sysctl_calculated_value: a \'base\' value must be set!},
      )
    }
  end

  context 'calculation valid, idempotent' do
    it { 
      is_expected.to run.with_params(
        [
          {
            'calc_type' => 'calculated',
            'base' => 42,
          }
        ],
        0
      ).and_return(' 42')
    }
  end

  context 'calculation valid, multiply only' do
    it { 
      is_expected.to run.with_params(
        [
          {
            'calc_type' => 'calculated',
            'base' => 42,
            'multiplier' => 2,
          }
        ],
        0
      ).and_return(' 84')
    }
  end

  context 'calculation valid, divide only' do
    it { 
      is_expected.to run.with_params(
        [
          {
            'calc_type' => 'calculated',
            'base' => 42,
            'divisor' => 2,
          }
        ],
        0
      ).and_return(' 21')
    }
  end

  context 'calculation valid, full calculation' do
    it { 
      is_expected.to run.with_params(
        [
          {
            'calc_type' => 'calculated',
            'base' => 1024,
            'multiplier' => 2,
            'divisor' => 32,
          }
        ],
        0
      ).and_return(' 64')
    }
  end

  context 'calculation valid, recursion 3 levels' do
    it { 
      is_expected.to run.with_params(
        [
          {
            'calc_type' => 'value',
            'value' => 10,
          },
          {
            'calc_type' => 'value',
            'value' => 20,
          },
          {
            'calc_type' => 'calculated',
            'base' => 10,
            'multiplier' => 3,
          }
        ],
        0
      ).and_return(' 10 20 30')
    }
  end
end
