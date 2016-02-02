require 'spec_helper'

describe 'test_apply', :type => :class do
  context 'on all OSes' do
    let :facts do
      {
        :id                     => 'root',
        :kernel                 => 'Linux',
        :osfamily               => 'RedHat',
        :operatingsystem        => 'RedHat',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    it { should contain_class("test_notify") }
    it { should contain_notify("test_notify").without_noop}
    it { should contain_notify("notify_false_change_window").with_noop(true)}
  end
end
