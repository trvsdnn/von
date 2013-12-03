module Von
  module Counters
    class Best
      include Commands

      def initialize(field, periods = nil)
        @field   = field.to_sym
        @periods = periods || []
      end

      def hash_key
        @hash_key ||= "#{Von.config.namespace}:counters:bests:#{@field}"
      end

      def best_total(time_unit)
        hget("#{hash_key}:#{time_unit}:best", 'total').to_i
      end

      def best_timestamp(time_unit)
        hget("#{hash_key}:#{time_unit}:best", 'timestamp')
      end

      def current_total(time_unit)
        hget("#{hash_key}:#{time_unit}:current", 'total').to_i
      end

      def current_timestamp(time_unit)
        hget("#{hash_key}:#{time_unit}:current", 'timestamp')
      end

      def increment(value=1, timestamp=Time.now)
        return if @periods.empty?

        @periods.each do |period|
          _current_timestamp = current_timestamp(period.time_unit)
          _current_total     = current_total(period.time_unit)

          if period.timestamp(timestamp) != _current_timestamp
            # changing current period
            hset("#{hash_key}:#{period.time_unit}:current", 'total', value)
            hset("#{hash_key}:#{period.time_unit}:current", 'timestamp', period.timestamp(timestamp))

            if best_total(period) < _current_total
              hset("#{hash_key}:#{period.time_unit}:best", 'total', _current_total)
              hset("#{hash_key}:#{period.time_unit}:best", 'timestamp', _current_timestamp)
            end
          else
            hincrby("#{hash_key}:#{period.time_unit}:current", 'total', value)
          end
        end
      end

      def count(time_unit)
        _current_timestamp = current_timestamp(time_unit)
        _current_total     = current_total(time_unit)
        _best_timestamp    = best_timestamp(time_unit)
        _best_total        = best_total(time_unit)

        if _current_total > _best_total
          { timestamp: _current_timestamp, count: _current_total }
        else
          { timestamp: _best_timestamp, count: _best_total }
        end
      end

    end
  end
end
