require 'test_helper'

describe Von::Counter do
  Counter = Von::Counter

  before :each do
    Timecop.freeze(Time.local(2013, 01))
    Von.config.init!
    connection = Von::TestConnection.new
    @store     = connection.store
    Von.expects(:connection).returns(connection).at_least_once
  end

  it "increments the total counter if given a single key" do
    Counter.new('foo').increment

    @store.has_key?('von:foo').must_equal true
    @store['von:foo']['total'].must_equal 1

    Counter.new('foo').increment
    @store['von:foo']['total'].must_equal 2
  end

  it "increments the total counter for a key and it's parent keys" do
    Counter.new('foo:bar').increment

    @store.has_key?('von:foo').must_equal true
    @store['von:foo']['total'].must_equal 1
    @store.has_key?('von:foo:bar').must_equal true
    @store['von:foo:bar']['total'].must_equal 1

    Counter.new('foo:bar').increment
    @store['von:foo']['total'].must_equal 2
    @store['von:foo:bar']['total'].must_equal 2
  end

  it "increments a month counter" do
    Von.configure do |config|
      config.counter 'foo', :monthly => 1
    end

    Counter.new('foo').increment
    Counter.new('foo').increment

    @store.has_key?('von:foo').must_equal true
    @store.has_key?('von:foo:monthly').must_equal true
    @store['von:foo']['total'].must_equal 2
    @store['von:foo:monthly']['2013-01'].must_equal 2
    @store['von:lists:foo:monthly'].size.must_equal 1
  end

  it "expires counters past the limit" do
    Von.configure do |config|
      config.counter 'foo', :monthly => 1
    end

    Counter.new('foo').increment
    Timecop.freeze(Time.local(2013, 02))
    Counter.new('foo').increment

    @store.has_key?('von:foo').must_equal true
    @store.has_key?('von:foo:monthly').must_equal true
    @store['von:foo']['total'].must_equal 2
    @store['von:foo:monthly'].has_key?('2013-02').must_equal true
    @store['von:lists:foo:monthly'].size.must_equal 1
  end

  it "gets a total count for a counter" do
    Counter.new('foo').increment
    Counter.new('foo').increment
    Counter.new('foo').increment

    Von.count('foo').must_equal 3
  end

  it "gets a count for a time period and 0s missing entries" do
    Von.configure do |config|
      config.counter 'foo', :monthly => 1, :hourly => 6
    end

    Timecop.freeze(Time.local(2013, 02, 01, 05))
    Counter.new('foo').increment
    Timecop.freeze(Time.local(2013, 02, 01, 07))
    Counter.new('foo').increment

    Von.count('foo').must_equal 2

    Von.count('foo', :monthly).must_equal [{"2013-02" => 2}]
    Von.count('foo', :hourly).must_equal [
      {"2013-02-01 02:00"=>0},
      {"2013-02-01 03:00"=>0},
      {"2013-02-01 04:00"=>0},
      {"2013-02-01 05:00"=>1},
      {"2013-02-01 06:00"=>0},
      {"2013-02-01 07:00"=>1}
    ]
  end

end
