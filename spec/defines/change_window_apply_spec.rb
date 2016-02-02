require 'spec_helper'
require 'hiera'

describe 'change_window::apply', :type => :define do
  let :title do
    'test_change_window_apply'
  end
  let :default_params do
    {
      :class_list => [ 'test_notify', { 'notify' => { 'test_change_window_apply' => {} } } ]
    }
  end

  describe 'with_false_change_window' do
    let :params do
      default_params.merge({
        :change_window_set => 'false_change_window'
      })
    end
    it { is_expected.to contain_notify('test_change_window_apply').with_noop(true) }
    it { is_expected.to contain_notify('test_notify').with_noop(true) }
    it { is_expected.to contain_class('test_notify') }
  end


  describe 'with_true_change_window' do
    let :params do
      default_params.merge({
        :change_window_set => 'true_change_window'
      })
    end
    it { is_expected.to contain_notify('test_change_window_apply').without_noop }
    it { is_expected.to contain_notify('test_notify').without_noop }
    it { is_expected.to contain_class('test_notify') }
  end

  describe 'with_bad_change_window_set' do
    let :params do
      default_params.merge({
        :change_window_set => 'bad_change_window_set'
      })
    end
    it { is_expected.not_to compile }
  end

end
