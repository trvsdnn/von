module Von
  class BestCounter

    def initialize(parent)
      @parent  = parent
      @field   = parent.field
      @periods = Von.config.bests[@field]
    end

    # Returns the Redis hash key used for storing counts for this Counter
    def hash_key
      @hash_key ||= "#{Von.config.namespace}:counters:bests:#{@field}"
    end

    def increment
      return if @periods.nil?
      
      @periods.each do |period|
        # TODO: subclass counter (or somethin) and add hincrby/etc helpers
        
        current_timestamp = Von.connection.hget("#{hash_key}:#{period}:current", 'timestamp')
        
        # TODO: this logic "seems" backwards, rethink current_timestamp
        if period.timestamp != current_timestamp
          # changing current period
          current_total  = Von.connection.hget("#{hash_key}:#{period}:current", 'total').to_i
          best_total     = Von.connection.hget("#{hash_key}:#{period}:best", 'total').to_i
          
          Von.connection.hset("#{hash_key}:#{period}:current", 'total', 1)
          Von.connection.hset("#{hash_key}:#{period}:current", 'timestamp', period.timestamp)
                    
          if best_total < current_total
            Von.connection.hset("#{hash_key}:#{period}:best", 'total', current_total)
            Von.connection.hset("#{hash_key}:#{period}:best", 'timestamp', current_timestamp)
          end
        else
          Von.connection.hincrby("#{hash_key}:#{period}:current", 'total', 1)
        end
      end
    end

  end
end
