module Von
  module Counters
    class Period
      include Von::Counters::Commands

      def initialize(field, periods = nil)
        @field   = field.to_sym
        @periods = periods || []
      end

      # Returns the Redis hash key used for storing counts for this Period
      def hash_key(period)
        "#{Von.config.namespace}:counters:#{@field}:#{period}"
      end

      # Returns the Redis list key used for storing current "active" counters
      def list_key(period)
        "#{Von.config.namespace}:lists:#{@field}:#{period}"
      end

      def increment
        return if @periods.empty?

        @periods.each do |period|
          _hash_key = hash_key(period)
          _list_key = list_key(period)

          hincrby(_hash_key, period.timestamp, 1)

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
      def count(period)
        return if @periods.empty?

        counts     = []
        this_period = nil
        _period     = @periods.select { |p| p.period == period }.first

        _period.length.times do |i|
          this_period = _period.prev(i)
          counts.unshift(this_period)
        end

        keys = hgetall(hash_key(period))
        counts.map { |date| { date => keys.fetch(date, 0).to_i }}
      end

    end
  end
end
