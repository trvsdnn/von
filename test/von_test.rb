require 'test_helper'

describe Von do

  before :each do
    Timecop.freeze(Time.local(2013, 01, 01, 01, 01))
    Von.config.init!
    @redis = Redis.new
    @redis.flushall
  end

  it "increments a counter and counts it" do
    3.times { Von.increment('foo') }
    Von.count('foo').total.must_equal 3
  end

  it "increments a counter and parent counters and counts them" do
    3.times { Von.increment('foo:bar') }
    Von.count('foo').total.must_equal 3
    Von.count('foo:bar').total.must_equal 3
  end

  it "increments period/best counters and counts them" do
    Von.configure do |config|
      config.counter 'foo', :monthly => 2, :best => :day
    end

    Von.increment('foo')
    Timecop.freeze(Time.local(2013, 02, 03))
    Von.increment('foo')
    Von.increment('foo')
    Timecop.freeze(Time.local(2013, 03, 04))
    Von.increment('foo')

    Von.count('foo').best(:day).must_equal({ "2013-02-03" => 2 })
    Von.count('foo').per(:month).must_equal [{ "2013-02" => 2 }, { "2013-03" => 1 }]
  end

  it "raises a Redis connection errors if raise_connection_errors is true" do
    Von.config.raise_connection_errors = true
    Von.expects(:increment).raises(Redis::CannotConnectError)

    lambda { Von.increment('foo') }.must_raise Redis::CannotConnectError
  end

end
