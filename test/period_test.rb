require 'test_helper'

describe Von::Period do
  Period = Von::Period

  before :each do
    @config = Von::Config
    @config.init!
    Timecop.freeze(Time.local(2013, 01, 02, 03, 04))
  end

  it "intiializes given a period" do
    period = Period.new(:monthly)
    period.name.must_equal :monthly
    period.length.must_be_nil
    period.format.must_equal '%Y-%m'
  end

  it "intiializes given a time unit" do
    period = Period.new(:month)
    period.name.must_equal :monthly
    period.length.must_be_nil
    period.format.must_equal '%Y-%m'
  end

  it "intiializes given a period and length" do
    period = Period.new(:monthly, 3)
    period.name.must_equal :monthly
    period.length.must_equal 3
    period.format.must_equal '%Y-%m'
  end

  it "generates a timestamp for now" do
    Period.new(:minutely).timestamp.must_equal '2013-01-02 03:04'
    Period.new(:hourly).timestamp.must_equal '2013-01-02 03:00'
    Period.new(:daily).timestamp.must_equal '2013-01-02'
    Period.new(:weekly).timestamp.must_equal '2012-12-31'
    Period.new(:monthly).timestamp.must_equal '2013-01'
    Period.new(:yearly).timestamp.must_equal '2013'
  end

  it "knows the prev time period" do
    Period.new(:minutely).prev.must_equal '2013-01-02 03:03'
    Period.new(:hourly).prev.must_equal '2013-01-02 02:00'
    Period.new(:daily).prev.must_equal '2013-01-01'
    Period.new(:weekly).prev.must_equal '2012-12-24'
    Period.new(:monthly).prev.must_equal '2012-12'
    Period.new(:yearly).prev.must_equal '2012'
  end

  it "checks if the period is an hourly period" do
    Period.new(:minutely).wont_be :hours?
    Period.new(:hourly).must_be :hours?
    Period.new(:daily).wont_be :hours?
    Period.new(:weekly).wont_be :hours?
    Period.new(:monthly).wont_be :hours?
    Period.new(:yearly).wont_be :hours?
  end

  it "checks if the period is an hourly period" do
    Period.new(:minutely).must_be :minutes?
    Period.new(:hourly).wont_be :minutes?
    Period.new(:daily).wont_be :minutes?
    Period.new(:weekly).wont_be :minutes?
    Period.new(:monthly).wont_be :minutes?
    Period.new(:yearly).wont_be :minutes?
  end

  it "knows what time unit it is" do
    Period.new(:minutely).time_unit.must_equal :minute
    Period.new(:hourly).time_unit.must_equal :hour
    Period.new(:daily).time_unit.must_equal :day
    Period.new(:weekly).time_unit.must_equal :week
    Period.new(:monthly).time_unit.must_equal :month
    Period.new(:yearly).time_unit.must_equal :year
  end

  it "gets a time format from config" do
    Period.new(:minutely).format.must_equal Von.config.minutely_format
    Period.new(:hourly).format.must_equal Von.config.hourly_format
    Period.new(:daily).format.must_equal Von.config.daily_format
    Period.new(:weekly).format.must_equal Von.config.weekly_format
    Period.new(:monthly).format.must_equal Von.config.monthly_format
    Period.new(:yearly).format.must_equal Von.config.yearly_format
  end

end
