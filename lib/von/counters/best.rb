module Von
  module Counters
    class Best

      def initialize(field, periods = nil)
        @field   = field.to_sym
        @periods = periods || []
      end

      def hash_key
        @hash_key ||= "#{Von.config.namespace}:counters:bests:#{@field}"
      end

      def best_total(period)
        Von.connection.hget("#{hash_key}:#{period}:best", 'total').to_i
      end

      def best_timestamp(period)
        Von.connection.hget("#{hash_key}:#{period}:best", 'timestamp')
      end

      def current_total(period)
        Von.connection.hget("#{hash_key}:#{period}:current", 'total').to_i
      end

      def current_timestamp(period)
        Von.connection.hget("#{hash_key}:#{period}:current", 'timestamp')
      end

      def increment
        return if @periods.empty?

        @periods.each do |period|
          # TODO: subclass counter (or somethin) and add hincrby/etc helpers
          _current_timestamp = current_timestamp(period)
          _current_total     = current_total(period)

          if period.timestamp != _current_timestamp
            # changing current period
            Von.connection.hset("#{hash_key}:#{period}:current", 'total', 1)
            Von.connection.hset("#{hash_key}:#{period}:current", 'timestamp', period.timestamp)

            if best_total(period) < _current_total
              Von.connection.hset("#{hash_key}:#{period}:best", 'total', _current_total)
              Von.connection.hset("#{hash_key}:#{period}:best", 'timestamp', _current_timestamp)
            end
          else
            Von.connection.hincrby("#{hash_key}:#{period}:current", 'total', 1)
          end
        end
      end

      def count(period)
        if current_timestamp > best_timestamp
          { current_timestamp => current_total }
        else
          { best_timestamp => best_total }
        end
      end

    end
  end
end