require 'test_helper'

require 'test_helper'

describe Von::Config do

  before :each do
    @config = Von::Config
    @config.reset!
  end

  it 'intiializes a config with defaults' do
    @config.namespace.must_equal 'von'
    @config.hourly_format.must_equal '%Y-%m-%d %H:00'
  end

  it 'initializes a config with a hash' do
    attributes = {
      :namespace => 'foo',
    }

    @config.from_hash!(attributes)

    attributes.each do |key, value|
      @config.send(key).must_equal value
    end
  end

  it 'initializes a config and overloads it with a block' do
    @config.configure do
      self.namespace = 'something'
    end

    @config.namespace.must_equal 'something'
  end

  it 'stores counter options per key and retrieves them' do
    options = { :monthly => 3, :total => false }

    @config.configure do
      counter 'bar', options
    end

    @config.namespace.must_equal 'von'
    @config.counter_options('bar').must_equal options
  end

  it 'stores counter options per key and retrieves them' do
    options = { :monthly => 3, :total => false }

    @config.configure do
      counter 'bar', options
    end

    @config.namespace.must_equal 'von'
    @config.counter_periods('bar').must_equal :monthly => 3
  end

end