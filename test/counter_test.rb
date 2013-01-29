require 'test_helper'

describe Von::Counter do
  Counter = Von::Counter

  before :each do
    Timecop.freeze(Time.local(2013, 01, 01, 01, 01))
    Von.config.init!
    @redis = Redis.new
    @redis.flushall
  end

  it "increments the total counter if given a single key" do
    Counter.increment('foo')
    @redis.hget('von:counters:foo', 'total').must_equal '1'

    Counter.increment('foo')
    @redis.hget('von:counters:foo', 'total').must_equal '2'
  end

  it "increments the total counter for a key and it's parent keys" do
    Counter.increment('foo:bar')
  
    @redis.hget('von:counters:foo', 'total').must_equal '1'
    @redis.hget('von:counters:foo:bar', 'total').must_equal '1'
  
    Counter.increment('foo:bar')
    @redis.hget('von:counters:foo', 'total').must_equal '2'
    @redis.hget('von:counters:foo:bar', 'total').must_equal '2'
  end
  
  it "increments a month counter" do
    Von.configure do |config|
      config.counter 'foo', :monthly => 1
    end
  
    Counter.increment('foo')
    Counter.increment('foo')
  
    @redis.hget('von:counters:foo', 'total').must_equal '2'
    @redis.hget('von:counters:foo:monthly', '2013-01').must_equal '2'
    @redis.lrange('von:lists:foo:monthly', 0, -1).size.must_equal 1
    @redis.lrange('von:lists:foo:monthly', 0, -1).first.must_equal '2013-01'
  end
  
  it 'increments a minute counter' do
    Von.configure do |config|
      config.counter 'foo', :minutely => 60
    end
  
    Counter.increment('foo')
    Counter.increment('foo')
  
    @redis.hget('von:counters:foo', 'total').must_equal '2'
    @redis.hget('von:counters:foo:minutely', '2013-01-01 01:01').must_equal '2'
    @redis.lrange('von:lists:foo:minutely', 0, -1).size.must_equal 1
    @redis.lrange('von:lists:foo:minutely', 0, -1).first.must_equal '2013-01-01 01:01'
  end
  
  it "expires counters past the limit" do
    Von.configure do |config|
      config.counter 'foo', :monthly => 1
    end
  
    Counter.increment('foo')
    Timecop.freeze(Time.local(2013, 02))
    Counter.increment('foo')
  
    @redis.hget('von:counters:foo', 'total').must_equal '2'
    @redis.hget('von:counters:foo:monthly', '2013-02').must_equal '1'
    @redis.lrange('von:lists:foo:monthly', 0, -1).size.must_equal 1
    @redis.lrange('von:lists:foo:monthly', 0, -1).first.must_equal '2013-02'
  end
  
  it "gets a total count for a counter" do
    Counter.increment('foo')
    Counter.increment('foo')
    Counter.increment('foo')
  
    Von.count('foo').must_equal 3
  end
  
  it "gets a count for a time period and 0s missing entries" do
    Von.configure do |config|
      config.counter 'foo', :monthly => 1, :hourly => 6
    end
  
    Timecop.freeze(Time.local(2013, 02, 01, 05))
    Counter.increment('foo')
    Timecop.freeze(Time.local(2013, 02, 01, 07))
    Counter.increment('foo')
  
    Von.count('foo').must_equal 2
  
    Von.count('foo', :monthly).must_equal [{"2013-02" => 2}]
    Von.count('foo', :hourly).must_equal [
      { "2013-02-01 02:00" => 0 },
      { "2013-02-01 03:00" => 0 },
      { "2013-02-01 04:00" => 0 },
      { "2013-02-01 05:00" => 1 },
      { "2013-02-01 06:00" => 0 },
      { "2013-02-01 07:00" => 1 }
    ]
  end

end
