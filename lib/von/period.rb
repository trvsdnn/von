module Von
  class Period
    AVAILABLE_PERIODS = [ :hourly, :daily, :weekly, :monthly, :yearly ]

    attr_reader :length

    def initialize(counter, period, length)
      @counter = counter
      @period  = period
      @length  = length
      @now     = Time.now
    end

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

    def hours?
      @period == :hourly
    end

    def format
      @format ||= Von.config.send(:"#{@period}_format")
    end

    def hash
      @hash ||= "#{Von.config.namespace}:#{@counter}:#{@period}"
    end

    def list
      @list ||= "#{Von.config.namespace}:lists:#{@counter}:#{@period}"
    end

    def field
      @now.strftime(format)
    end
  end
end
