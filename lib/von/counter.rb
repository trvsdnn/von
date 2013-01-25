module Von
  class Counter
    CHILD_REGEX  = /:[^:]+\z/
    PARENT_REGEX = /:?[^:]+\z/

    # Initialize a new Counter
    #
    # field - counter field name
    def initialize(field)
      @field = field.to_sym
    end

    # Returns options specified in config for this Counter
    def options
      @options ||= Von.config.counter_options(@field)
    end

    # Returns periods specified in config for this Counter
    def periods
      @periods ||= options.select { |k|
        Period::AVAILABLE_PERIODS.include?(k)
      }.inject({}) { |h, (p, l)| h[p] = Period.new(@field, p, l); h }
    end

    # Returns the Redis hash key used for storing counts for this Counter
    def hash_key
      @hash_key ||= "#{Von.config.namespace}:#{@field}"
    end

    # Increment the Redis count for this Counter.
    # If the field is a Period, we increment the Period.
    #
    # field - the Redis field containing the count
    def increment(field = 'total')
      if field.is_a?(Period)
        increment_period(field)
      else
        Von.connection.hincrby(hash_key, field, 1)
        increment_parents
      end
    end

    # Increment the Redis count for a Period
    #
    # period - The Period to increment
    def increment_period(period)
      Von.connection.hincrby(period.hash_key, period.field, 1)
      unless Von.connection.lrange(period.list_key, 0, -1).include?(period.field)
        Von.connection.rpush(period.list_key, period.field)
      end

      if Von.connection.llen(period.list_key) > period.length
        expired_counter = Von.connection.lpop(period.list_key)
        Von.connection.hdel(period.hash_key, expired_counter)
      end
    end

    # Increment the parent keys of this Counter.
    # Example: increment('something:foo:bar') would increment
    # 'something:foo:bar', 'something:foo', 'something'
    def increment_parents
      field = @field.to_s
      return if field !~ CHILD_REGEX

      parents = field.sub(CHILD_REGEX, '')

      until parents.empty? do
        Von.connection.hincrby("#{Von.config.namespace}:#{parents}", 'total', 1)
        parents.sub!(PARENT_REGEX, '')
      end
    end

    # Lookup the count for this Counter in Redis.
    # If a Period argument is given we lookup the count for
    # all of the possible units (not expired), zeroing ones that
    # aren't set in Redis already.
    #
    # period - A Period to lookup
    #
    # Returns an Integer representing the count or an Array of counts.
    def count(period = nil)
      if period.nil?
        Von.connection.hget(hash_key, 'total')
      else
        _count   = []
        _period  = periods[period]
        now      = DateTime.now.beginning_of_hour

        _period.length.times do
          this_period = now.strftime(_period.format)
          _count.unshift(this_period)
          now = _period.hours? ? now.ago(3600) : now.send(:"prev_#{_period.time_unit}")
        end

        keys = Von.connection.hgetall("#{hash_key}:#{period}")
        _count.map { |date| { date => keys.fetch(date, 0) }}
      end
    end

  end
end
