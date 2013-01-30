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
      period  = Period.unit_to_period(unit)
      
      if period.nil?
        raise ArgumentError, "`#{unit}' is an unknown time unit"
      else
        Counters::Period.new(@field, periods).count(period)
      end
    rescue Redis::BaseError => e
      raise e if Von.config.raise_connection_errors
    end
    
    def best(unit)
      periods = Von.config.bests[@field]
      period  = Period.unit_to_period(unit)
      
      if period.nil?
        raise ArgumentError, "`#{unit}' is an unknown time unit"
      else
        Counters::Best.new(@field, periods).count(period)
      end
    rescue Redis::BaseError => e
      raise e if Von.config.raise_connection_errors
    end
      
  end
end
