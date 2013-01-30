require 'test_helper'

describe Von::Counter do
  Counter = Von::Counter

  before :each do
    Timecop.freeze(Time.local(2013, 01, 01, 01, 01))
    Von.config.init!
    @redis = Redis.new
    @redis.flushall
  end

  it "returns count for key" do
    3.times { Von.increment('foo') }
    Counter.new('foo').total.must_equal 3
  end

  it "returns count for key and parent keys" do
    3.times { Von.increment('foo:bar') }
    Counter.new('foo').total.must_equal 3
    Counter.new('foo:bar').total.must_equal 3
  end


  it "returns counts for a given period" do
    Von.configure do |config|
      config.counter 'foo', :monthly => 2
    end

    Von.increment('foo')
    Timecop.freeze(Time.local(2013, 02))
    Von.increment('foo')
    Timecop.freeze(Time.local(2013, 03))
    Von.increment('foo')

    Counter.new('foo').per(:month).must_equal [{ "2013-02" => 1 }, { "2013-03" => 1 }]
  end
  
  it "returns best count for a given period" do
    Von.configure do |config|
      config.counter 'foo', :best => [:minute, :week]
    end

    Von.increment('foo')

    Timecop.freeze(Time.local(2013, 01, 13, 06, 05))
    4.times { Von.increment('foo') }
    Timecop.freeze(Time.local(2013, 01, 20, 06, 10))
    3.times { Von.increment('foo') }
    
    Counter.new('foo').best(:minute).must_equal({ "2013-01-13 06:05" => 4 })
    Counter.new('foo').best(:week).must_equal({ "2013-01-07" => 4 })
  end


end
