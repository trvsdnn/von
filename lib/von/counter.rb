module Von
  class Counter

    def initialize(field)
      @field = field.to_sym
    end

    def to_s
      Counters::Total.new(@field).count.to_s
    rescue Redis::BaseError => e
      raise e if Von.config.raise_connection_errors
    end

    def to_i
      Counters::Total.new(@field).count
    rescue Redis::BaseError => e
      raise e if Von.config.raise_connection_errors
    end

    def total
      Counters::Total.new(@field).count
    rescue Redis::BaseError => e
      raise e if Von.config.raise_connection_errors
    end

    def per(unit)
      periods = Von.config.periods[@field]

      if Period.time_unit_exists?(unit)
        Counters::Period.new(@field, periods).count(unit)
      else
        raise ArgumentError, "`#{unit}' is an unknown time unit"
      end
    rescue Redis::BaseError => e
      raise e if Von.config.raise_connection_errors
    end

    def best(unit)
      periods = Von.config.bests[@field]

      if Period.time_unit_exists?(unit)
        Counters::Best.new(@field, periods).count(unit)
      else
        raise ArgumentError, "`#{unit}' is an unknown time unit"
      end
    rescue Redis::BaseError => e
      raise e if Von.config.raise_connection_errors
    end

    def this(unit)
      periods = Von.config.currents[@field]

      if Period.time_unit_exists?(unit)
        Counters::Current.new(@field, periods).count(unit)
      else
        raise ArgumentError, "`#{unit}' is an unknown time unit"
      end
    rescue Redis::BaseError => e
      raise e if Von.config.raise_connection_errors
    end

    alias :current :this

    def today
      periods = Von.config.currents[@field]

      Counters::Current.new(@field, periods).count(:day)
    end

  end
end
