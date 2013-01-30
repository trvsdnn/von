module Von
  class Period
    AVAILABLE_PERIODS = [ :minutely, :hourly, :daily, :weekly, :monthly, :yearly ]
    TIME_UNITS = {
      :minutely => :minute,
      :hourly   => :hour,
      :daily    => :day,
      :weekly   => :week,
      :monthly  => :month,
      :yearly   => :year
    }
    TIME_PERIODS = TIME_UNITS.invert
    
    attr_reader :period
    attr_reader :counter_key
    attr_reader :length
    attr_reader :format

    # Initialize a Period object
    #
    # counter - the field name for the counter
    # period - the time period one of AVAILABLE_PERIODS
    # length - length of period
    def initialize(counter_key, period, length = nil)
      @counter_key = counter_key
      @period      = period.to_sym
      @length      = length
      @format      = Von.config.send(:"#{@period}_format")
    end
    
    def to_s
      @period.to_s
    end

    # Returns a Symbol representing the time unit
    # for the current period.
    def time_unit
      @time_unit ||= TIME_UNITS[@period]
    end

    # Returns True or False if the period is hourly
    def hours?
      @period == :hourly
    end

    def now
      # TODO: this may break minutes
      DateTime.now.beginning_of_hour
    end

    def prev
      hours? ? now.ago(3600) : now.send(:"prev_#{_period.time_unit}")
    end

    # Returns the Redis hash key used for storing counts for this Period
    def hash_key
      @hash ||= "#{Von.config.namespace}:counters:#{@counter_key}:#{@period}"
    end

    # Returns the Redis list key used for storing current "active" counters
    def list_key
      @list ||= "#{Von.config.namespace}:lists:#{@counter_key}:#{@period}"
    end

    # Returns the Redis field representation used for storing the count value
    # TODO: rename this
    def field
      Time.now.strftime(format)
    end
    alias :timestamp :field

    def self.exists?(period)
      AVAILABLE_PERIODS.include?(period)
    end
  end
end
