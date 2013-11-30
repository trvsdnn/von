module Von
  class Period
    PERIOD_MAPPING = {
      minutely: :minute,
      hourly: :hour,
      daily: :day,
      weekly: :week,
      monthly: :month,
      yearly: :year
    }

    AVAILABLE_PERIODS    = PERIOD_MAPPING.keys
    AVAILABLE_TIME_UNITS = PERIOD_MAPPING.values

    attr_reader :name
    attr_reader :length
    attr_reader :format

    # Initialize a Period object
    #
    # period - the time period one of AVAILABLE_PERIODS
    # length - length of period
    def initialize(period, length = nil)
      name = period.to_sym
      if AVAILABLE_PERIODS.include?(name)
        @name = name
      elsif AVAILABLE_TIME_UNITS.include?(name)
        @name = PERIOD_MAPPING.invert[name]
      else
        raise ArgumentError, "`#{period}' is not a valid period"
      end
      @length = length
      @format = Von.config.send(:"#{@name}_format")
    end

    # Returns a Symbol representing the time unit
    # for the current period.
    def time_unit
      @time_unit ||= PERIOD_MAPPING[@name]
    end

    # Returns True or False if the period is hourly
    def hours?
      @name == :hourly
    end

    # Returns True or False if the period is minutely
    def minutes?
      @name == :minutely
    end

    def beginning(time)
      if minutes?
        time.change(seconds: 0)
      else
        time.send(:"beginning_of_#{time_unit}")
      end
    end

    def prev(unit = 1)
      beginning(unit.send(time_unit.to_sym).ago).strftime(@format)
    end

    def timestamp(time=Time.now)
      beginning(time).strftime(format)
    end

    def self.unit_to_period(time_unit)
      PERIOD_MAPPING.invert[time_unit]
    end

    def self.exists?(period)
      AVAILABLE_PERIODS.include?(period)
    end

    def self.time_unit_exists?(time_unit)
      AVAILABLE_TIME_UNITS.include?(time_unit)
    end
  end
end
