module Von
  module Counters
    class Period
      include Commands

      def initialize(field, periods = nil)
        @field   = field.to_sym
        @periods = periods || []
      end

      # Returns the Redis hash key used for storing counts for this Period
      def hash_key(time_unit)
        "#{Von.config.namespace}:counters:#{@field}:#{time_unit}"
      end

      # Returns the Redis list key used for storing current "active" counters
      def list_key(time_unit)
        "#{Von.config.namespace}:lists:#{@field}:#{time_unit}"
      end

      def increment(value=1)
        return if @periods.empty?

        @periods.each do |period|
          _hash_key = hash_key(period.time_unit)
          _list_key = list_key(period.time_unit)

          hincrby(_hash_key, period.timestamp, value)

          unless lrange(_list_key, 0, -1).include?(period.timestamp)
            rpush(_list_key, period.timestamp)
          end

          if llen(_list_key) > period.length
            expired_counter = lpop(_list_key)
            hdel(_hash_key, expired_counter)
          end
        end
      end

      # Count the fields for the given time period for this Counter.
      #
      # Returns an Array of Hashes representing the count
      def count(time_unit)
        return if @periods.empty?

        counts  = []
        _period = @periods.select { |p| p.time_unit == time_unit }.first

        _period.length.times do |i|
          this_period = _period.prev(i)
          counts.unshift(this_period)
        end

        keys = hgetall(hash_key(time_unit))
        counts.map { |date| { timestamp: date, count: keys.fetch(date, 0).to_i }}
      end

    end
  end
end
