require 'test_helper'

describe Von do

  before :each do
    Von.config.init!
  end

  it "increments a counter and counts it" do
    Redis.new.flushall
    
    Von.increment('foo')
    Von.increment('foo')
    Von.count('foo').must_equal 2
  end

  it "raises a Redis connection errors if raise_connection_errors is true" do
    Von.config.raise_connection_errors = true
    Von.expects(:increment).raises(Redis::CannotConnectError)

    lambda { Von.increment('foo') }.must_raise Redis::CannotConnectError
  end

end
