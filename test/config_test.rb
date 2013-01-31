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

  it "allows periods to be set via counter method" do
    Von.configure do |config|
      config.counter 'bar', :monthly => 3, :daily => 6
    end

    Von.config.periods[:bar].length.must_equal 2
    Von.config.periods[:bar].first.name.must_equal :monthly
    Von.config.periods[:bar].first.length.must_equal 3
    Von.config.periods[:bar].last.name.must_equal :daily
    Von.config.periods[:bar].last.length.must_equal 6
  end

  it "allows bests to be set via counter method" do
    Von.configure do |config|
      config.counter 'bar', :best => :day
      config.counter 'foo', :best => [ :month, :year ]
    end

    Von.config.bests[:bar].first.must_be_instance_of Von::Period
    Von.config.bests[:bar].first.name.must_equal :daily
    Von.config.bests[:foo].first.must_be_instance_of Von::Period
    Von.config.bests[:foo].first.name.must_equal :monthly
    Von.config.bests[:foo].last.must_be_instance_of Von::Period
    Von.config.bests[:foo].last.name.must_equal :yearly
  end

end