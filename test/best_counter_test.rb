require 'test_helper'

describe Von::BestCounter do
  BestCounter = Von::BestCounter

  before :each do
    Timecop.freeze(Time.local(2013, 01, 01, 06))
    Von.config.init!
    @redis = Redis.new
    @redis.flushall
  end

  it "increments the best counter for a period" do
    counter = BestCounter.new('foo', [ Von::Period.new(:day) ])

    counter.increment

    Timecop.freeze(Time.local(2013, 01, 02))
    4.times { counter.increment }
    Timecop.freeze(Time.local(2013, 01, 03))
    3.times { counter.increment }

    @redis.hget('von:counters:bests:foo:daily:current', 'timestamp').must_equal '2013-01-03'
    @redis.hget('von:counters:bests:foo:daily:current', 'total').must_equal '3'
    @redis.hget('von:counters:bests:foo:daily:best', 'timestamp').must_equal '2013-01-02'
    @redis.hget('von:counters:bests:foo:daily:best', 'total').must_equal '4'
  end

  it "increments the best counter for multiple periods" do
    counter = BestCounter.new('foo', [
      Von::Period.new(:minute),
      Von::Period.new(:week),
    ])

    counter.increment

    Timecop.freeze(Time.local(2013, 01, 13, 06, 05))
    4.times { counter.increment }
    Timecop.freeze(Time.local(2013, 01, 20, 06, 10))
    3.times { counter.increment }

    @redis.hget('von:counters:bests:foo:minutely:current', 'timestamp').must_equal '2013-01-20 06:10'
    @redis.hget('von:counters:bests:foo:minutely:current', 'total').must_equal '3'
    @redis.hget('von:counters:bests:foo:minutely:best', 'timestamp').must_equal '2013-01-13 06:05'
    @redis.hget('von:counters:bests:foo:minutely:best', 'total').must_equal '4'

    @redis.hget('von:counters:bests:foo:weekly:current', 'timestamp').must_equal '2013-01-14'
    @redis.hget('von:counters:bests:foo:weekly:current', 'total').must_equal '3'
    @redis.hget('von:counters:bests:foo:weekly:best', 'timestamp').must_equal '2013-01-07'
    @redis.hget('von:counters:bests:foo:weekly:best', 'total').must_equal '4'
  end

end
