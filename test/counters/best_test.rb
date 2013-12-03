require 'test_helper'

describe Von::Counters::Best do
  BestCounter = Von::Counters::Best

  before :each do
    Timecop.freeze(Time.local(2013, 01, 01, 06))
    Von.config.init!
    @redis = Redis.new
    @redis.flushall
  end

  it "increments the best counter for a period" do
    counter = BestCounter.new('foo', [ Von::Period.new(:day) ])

    counter.increment

    4.times { counter.increment(2, Time.local(2013, 01, 02)) }
    3.times { counter.increment(1, Time.local(2013, 01, 03)) }

    @redis.hget('von:counters:bests:foo:day:current', 'timestamp').must_equal '2013-01-03'
    @redis.hget('von:counters:bests:foo:day:current', 'total').must_equal '3'
    @redis.hget('von:counters:bests:foo:day:best', 'timestamp').must_equal '2013-01-02'
    @redis.hget('von:counters:bests:foo:day:best', 'total').must_equal '8'
  end

  it "increments the best counter for multiple periods" do
    counter = BestCounter.new('foo', [
      Von::Period.new(:minute),
      Von::Period.new(:week),
    ])

    counter.increment

    4.times { counter.increment(2, Time.local(2013, 01, 13, 06, 05)) }
    3.times { counter.increment(1, Time.local(2013, 01, 20, 06, 10)) }

    @redis.hget('von:counters:bests:foo:minute:current', 'timestamp').must_equal '2013-01-20 06:10'
    @redis.hget('von:counters:bests:foo:minute:current', 'total').must_equal '3'
    @redis.hget('von:counters:bests:foo:minute:best', 'timestamp').must_equal '2013-01-13 06:05'
    @redis.hget('von:counters:bests:foo:minute:best', 'total').must_equal '8'

    @redis.hget('von:counters:bests:foo:week:current', 'timestamp').must_equal '2013-01-14'
    @redis.hget('von:counters:bests:foo:week:current', 'total').must_equal '3'
    @redis.hget('von:counters:bests:foo:week:best', 'timestamp').must_equal '2013-01-07'
    @redis.hget('von:counters:bests:foo:week:best', 'total').must_equal '8'
  end

end
