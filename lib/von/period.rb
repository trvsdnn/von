module Von
  class Period
    AVAILABLE_PERIODS = [ :hourly, :daily, :weekly, :monthly, :yearly ]

    def initialize(counter, period)
      @counter = counter
      @period  = period
      @now     = Time.now
    end

    def time_unit
      case @period
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

    def format
      Von.config.send(:"#{@period}_format")
    end

    def hash
      "#{Von.config.namespace}:#{@counter}:#{@period}"
    end

    def list
      "#{Von.config.namespace}:lists:#{@counter}:#{@period}"
    end

    def key
      @now.strftime(format)
    end
  end
end
