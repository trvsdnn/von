module Von
  class Period
    AVAILABLE_PERIODS = [ :hourly, :daily, :weekly, :monthly, :yearly ]

    attr_reader :counter
    attr_reader :length

    # Initialize a Period object
    #
    # counter - the field name for the counter
    # period - the time period one of AVAILABLE_PERIODS
    # length - length of period
    def initialize(counter, period, length)
      @counter = counter
      @period  = period
      @length  = length
      @now     = Time.now
    end

    # Returns a Symbol representing the time unit
    # for the current period.
    def time_unit
      @time_unit ||= case @period
      when :hourly
        :hour
      when :daily
        :day
      when :weekly
        :week
      when :monthly
        :month
      when :yearly
        :year
      end
    end

    # Returns True or False if the period is hourly
    def hours?
      @period == :hourly
    end

    # Returns the String DateTime format
    def format
      @format ||= Von.config.send(:"#{@period}_format")
    end

    # Returns the Redis hash key used for storing counts for this Period
    def hash_key
      @hash ||= "#{Von.config.namespace}:#{@counter}:#{@period}"
    end

    # Returns the Redis list key used for storing current "active" counters
    def list_key
      @list ||= "#{Von.config.namespace}:lists:#{@counter}:#{@period}"
    end

    # Returns the Redis field representation used for storing the count value
    def field
      @now.strftime(format)
    end
  end
end
