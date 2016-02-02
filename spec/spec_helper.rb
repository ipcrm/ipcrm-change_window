require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

include RspecPuppetFacts

require 'simplecov'
require 'simplecov-console'

RSpec.configure do |c|
  c.module_path  = File.expand_path(File.join(__FILE__, '../fixtures/modules'))
  c.manifest_dir = File.expand_path(File.join(__FILE__, '../fixtures/manifests'))
  c.hiera_config = File.expand_path(File.join(__FILE__, '../fixtures/hiera.yaml'))
end



SimpleCov.start do
  add_filter '/spec'
  add_filter '/vendor'
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ])
end
