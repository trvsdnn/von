require 'test_helper'

describe Von do

  before :each do
    Von.config.init!
  end

  it "increments a counter and counts it" do
    mock_connection!

    Von.increment('foo')
    Von.increment('foo')
    Von.count('foo').must_equal 2
  end

  it "raises a Redis connection errors if raise_connection_errors is true" do
    Von.config.raise_connection_errors = true
    Redis.expects(:new).raises(Redis::CannotConnectError)

    lambda { Von.increment('foo') }.must_raise Redis::CannotConnectError
  end

end
