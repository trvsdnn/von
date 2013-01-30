require 'test_helper'

describe Von::BestCounter do
  Counter = Von::BestCounter

  before :each do
    Timecop.freeze(Time.local(2013, 01, 01))
    Von.config.init!
    @redis = Redis.new
    @redis.flushall
  end

  it "increments the best counter for a period" do
    Von.configure do |config|
      config.counter 'foo', :best => :day
    end

    Counter.increment('foo')
    
    Timecop.freeze(Time.local(2013, 01, 02))
    10.times { Counter.increment('foo') }
    Timecop.freeze(Time.local(2013, 01, 03))
    3.times { Counter.increment('foo') }
    
    @redis.hget('von:counters:bests:foo:daily:current', 'timestamp').must_equal '2013-01-03'
    @redis.hget('von:counters:bests:foo:daily:current', 'total').must_equal '3'
    @redis.hget('von:counters:bests:foo:daily:best', 'timestamp').must_equal '2013-01-02'
    @redis.hget('von:counters:bests:foo:daily:best', 'total').must_equal '10'
  end

end
