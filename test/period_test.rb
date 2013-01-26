describe Von::Period do
  Period = Von::Period

  before :each do
    @config = Von::Config
    @config.init!
  end

  it "intiializes given a counter, period, and length" do
    period = Period.new('foo', :monthly, 6)
    period.counter_key.must_equal 'foo'
    period.length.must_equal 6
    period.format.must_equal '%Y-%m'
  end

  it "checks if the period is an hourly period" do
    Period.new('foo', :hourly, 6).must_be :hours?
    Period.new('foo', :daily, 6).wont_be :hours?
    Period.new('foo', :weekly, 6).wont_be :hours?
    Period.new('foo', :monthly, 6).wont_be :hours?
    Period.new('foo', :yearly, 6).wont_be :hours?
  end

  it "knows what time unit it is" do
    Period.new('foo', :hourly, 6).time_unit.must_equal :hour
    Period.new('foo', :daily, 6).time_unit.must_equal :day
    Period.new('foo', :weekly, 6).time_unit.must_equal :week
    Period.new('foo', :monthly, 6).time_unit.must_equal :month
    Period.new('foo', :yearly, 6).time_unit.must_equal :year
  end

  it "pulls a time format from config options" do
    Period.new('foo', :hourly, 6).format.must_equal Von.config.hourly_format
    Period.new('foo', :daily, 6).format.must_equal Von.config.daily_format
    Period.new('foo', :weekly, 6).format.must_equal Von.config.weekly_format
    Period.new('foo', :monthly, 6).format.must_equal Von.config.monthly_format
    Period.new('foo', :yearly, 6).format.must_equal Von.config.yearly_format
  end

  it "builds a redis hash key string" do
    field  = 'foo'
    period = :hourly
    period_obj = Period.new(field, period, 6)

    period_obj.hash_key.must_equal "#{@config.namespace}:counters:#{field}:#{period}"
  end

  it "builds a redis list key string" do
    field  = 'foo'
    period = :hourly
    period_obj = Period.new(field, period, 6)

    period_obj.list_key.must_equal "#{@config.namespace}:lists:#{field}:#{period}"
  end

  it "builds a redis field for the given period and current time" do
    Timecop.freeze(Time.local(2013, 02, 01, 05))
    Period.new('foo', :hourly, 6).field.must_equal '2013-02-01 05:00'
    Period.new('foo', :daily, 6).field.must_equal '2013-02-01'
    Period.new('foo', :weekly, 6).field.must_equal '2013-02-01'
    Period.new('foo', :monthly, 6).field.must_equal '2013-02'
    Period.new('foo', :yearly, 6).field.must_equal '2013'
  end

end