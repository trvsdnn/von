module Von
  class Period
    PERIOD_MAPPING = {
      :minutely => :minute,
      :hourly   => :hour,
      :daily    => :day,
      :weekly   => :week,
      :monthly  => :month,
      :yearly   => :year
    }
    AVAILABLE_PERIODS    = PERIOD_MAPPING.keys
    AVAILABLE_TIME_UNITS = PERIOD_MAPPING.values

    attr_reader :period
    attr_reader :length
    attr_reader :format

    # Initialize a Period object
    #
    # period - the time period one of AVAILABLE_PERIODS
    # length - length of period
    def initialize(period, length = nil)
      period = period.to_sym
      if AVAILABLE_PERIODS.include?(period)
        @period = period
      elsif AVAILABLE_TIME_UNITS.include?(period)
        @period = PERIOD_MAPPING.invert[period]
      else
        raise ArgumentError, "`#{period}' is not a valid period"
      end
      @length = length
      @format = Von.config.send(:"#{@period}_format")
    end

    def to_s
      @period.to_s
    end

    # Returns a Symbol representing the time unit
    # for the current period.
    def time_unit
      @time_unit ||= PERIOD_MAPPING[@period]
    end

    # Returns True or False if the period is hourly
    def hours?
      @period == :hourly
    end

    # Returns True or False if the period is minutely
    def minutes?
      @period == :minutely
    end

    def beginning(time)
      if minutes?
        time.change(:seconds => 0)
      else
        time.send(:"beginning_of_#{time_unit}")
      end
    end

    def prev
      beginning(1.send(time_unit.to_sym).ago).strftime(@format)
    end

    def timestamp
      beginning(Time.now).strftime(format)
    end

    def self.exists?(period)
      AVAILABLE_PERIODS.include?(period)
    end
  end
end
