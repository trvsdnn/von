require 'test_helper'

describe Von::Counters::Current do
  CurrentCounter = Von::Counters::Current

  before :each do
    Timecop.freeze(Time.local(2013, 01, 01, 06))
    Von.config.init!
    @redis = Redis.new
    @redis.flushall
  end

  it "increments the current counter for a period" do
    counter = CurrentCounter.new('foo', [ Von::Period.new(:day) ])

    4.times { counter.increment }
    3.times { counter.increment(2, Time.local(2013, 01, 02)) }

    @redis.hget('von:counters:currents:foo:day', 'timestamp').must_equal '2013-01-02'
    @redis.hget('von:counters:currents:foo:day', 'total').must_equal '6'
  end

  it "increments the current counter for multiple periods" do
    counter = CurrentCounter.new('foo', [
      Von::Period.new(:minute),
      Von::Period.new(:week),
    ])

    4.times { counter.increment }
    3.times { counter.increment(2, Time.local(2013, 01, 20, 06, 10)) }

    @redis.hget('von:counters:currents:foo:minute', 'timestamp').must_equal '2013-01-20 06:10'
    @redis.hget('von:counters:currents:foo:minute', 'total').must_equal '6'

    @redis.hget('von:counters:currents:foo:week', 'timestamp').must_equal '2013-01-14'
    @redis.hget('von:counters:currents:foo:week', 'total').must_equal '6'
  end

  it "counts acurrent counter for a period" do
    counter = CurrentCounter.new('foo', [
      Von::Period.new(:minute),
      Von::Period.new(:day),
    ])

    4.times { counter.increment }
    3.times { counter.increment(2, Time.local(2013, 01, 01, 06, 10)) }

    counter.count(:minute).must_equal 6
    counter.count(:day).must_equal 10
  end

end
