require 'test_helper'

describe Von::Config do

  before :each do
    @config = Von::Config
    @config.init!
  end

  it 'intiializes a config with defaults' do
    @config.namespace.must_equal 'von'
    @config.hourly_format.must_equal '%Y-%m-%d %H:00'
  end

  it 'initializes a config and overloads it with a block' do
    @config.namespace = 'something'

    @config.namespace.must_equal 'something'
  end

  it 'stores counter options per key and retrieves them' do
    options = { :monthly => 3, :total => false }

    @config.counter 'bar', options

    @config.namespace.must_equal 'von'
    @config.counter_options('bar').must_equal options
  end

  it "allows config options to be updated via configure" do
    options = { :monthly => 3, :total => false }

    Von.configure do |config|
      config.counter 'bar', options
    end

    Von.config.namespace.must_equal 'von'
    Von.config.counter_options('bar').must_equal options
  end

end