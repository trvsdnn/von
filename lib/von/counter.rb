module Von
  class Counter
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

    # Returns the Redis hash key used for storing counts for this Counter
    def hash_key
      @hash_key ||= "#{Von.config.namespace}:#{@field}"
    end

    # Increment the total count for this Counter
    # If the key has time periods specified, increment those.
    #
    # Returns the Integer total for the key
    def increment
      total = Von.connection.hincrby(hash_key, 'total', 1)

      increment_periods

      total
    end

    # Increment periods associated with this key
    def increment_periods
      return unless Von.config.periods.has_key?(@field.to_sym)

      Von.config.periods[@field.to_sym].each do |key, period|
        Von.connection.hincrby(period.hash_key, period.field, 1)
        unless Von.connection.lrange(period.list_key, 0, -1).include?(period.field)
          Von.connection.rpush(period.list_key, period.field)
        end

        if Von.connection.llen(period.list_key) > period.length
          expired_counter = Von.connection.lpop(period.list_key)
          Von.connection.hdel(period.hash_key, expired_counter)
        end
      end
    end

    # Increment the Redis count for this Counter.
    # If the key has parents, increment them as well.
    #
    # Returns the Integer total for the key
    def self.increment(field)
      total   = Counter.new(field).increment
      parents = field.sub(PARENT_REGEX, '')

      until parents.empty? do
        Counter.new(parents).increment
        parents.sub!(PARENT_REGEX, '')
      end

      total
    end

    # Count the "total" field for this Counter.
    #
    # Returns an Integer count
    def count
      Von.connection.hget(hash_key, 'total')
    end

    # Count the fields for the given time period for this Counter.
    #
    # Returns an Array of Hashes representing the count
    def count_period(period)
      return unless Von.config.period_defined_for?(@field, period)

      _counts   = []
      _period   = Von.config.periods[@field][period]
      now       = DateTime.now.beginning_of_hour

      _period.length.times do
        this_period = now.strftime(_period.format)
        _counts.unshift(this_period)
        now = _period.hours? ? now.ago(3600) : now.send(:"prev_#{_period.time_unit}")
      end

      keys = Von.connection.hgetall("#{hash_key}:#{period}")
      _counts.map { |date| { date => keys.fetch(date, 0) }}
    end

    # Lookup the count for this Counter in Redis.
    # If a Period argument is given we lookup the count for
    # all of the possible units (not expired), zeroing ones that
    # aren't set in Redis already.
    #
    # period - A Period to lookup
    #
    # Returns an Integer representing the count or an Array of counts.
    def self.count(field, period = nil)
      counter = Counter.new(field)

      if period.nil?
        counter.count
      else
        counter.count_period(period.to_sym)
      end
    end

  end
end
