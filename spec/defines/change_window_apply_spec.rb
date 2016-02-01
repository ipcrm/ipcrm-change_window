require 'spec_helper'
require 'hiera'

# let(:hiera_config) { 'spec/fixtures/hiera.yaml'}
# hiera = Hiera.new(:config => 'spec/fixtures/hiera.yaml')
# mydata = hiera.lookup('data', nil, nil)

describe 'change_window::apply', :type => :define do
  let :title do
    'test_change_window_apply'
  end
  let :default_params do
    {
      # :change_window_set => 'test_change_window',
      :class_list => [ { 'notify' => { 'test_change_window_apply' => {} } } ]
      # :class_list => [ 'test_notify' ],
    }
  end

  context 'false' do
    describe 'with_false_change_window' do
      let :params do
        default_params.merge({
          :change_window_set => 'false_change_window'
        })
      end
      it {
        Puppet::Util::Log.level = :debug
        Puppet::Util::Log.newdestination(:console)
        is_expected.to contain_notify('test_change_window_apply').with_noop(nil) }
    end
  end

  # describe 'with_bad_change_window_set' do
  #   let :params do
  #     default_params.merge({
  #       :change_window_set => 'bad_change_window_set'
  #     })
  #   end
  #   it {
  #     Puppet::Util::Log.level = :debug
  #     Puppet::Util::Log.newdestination(:console)
  #     is_expected.to contain_notify('test_change_window_apply').with_noop('true') }
  # end

  context 'true' do
    describe 'with_true_change_window' do
      let :params do
        default_params.merge({
          :change_window_set => 'true_change_window'
        })
      end
      it {
        Puppet::Util::Log.level = :debug
        Puppet::Util::Log.newdestination(:console)
        is_expected.to contain_notify('test_change_window_apply').with_noop('true') }
    end
  end


  # describe 'first test' do
  #   let let :params do
  #     default_params.merge({
  #       :change_window_set => 'test_change_window'
  #     })
  #   end
  #   it { should compile }
  #   it { is_expected.to contain_notify('test_change_window_apply').with_noop('true') }
  # end

end
