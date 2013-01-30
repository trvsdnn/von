module Von
  module Counters
    class Best
      include Von::Counters::Commands

      def initialize(field, periods = nil)
        @field   = field.to_sym
        @periods = periods || []
      end

      def hash_key
        @hash_key ||= "#{Von.config.namespace}:counters:bests:#{@field}"
      end

      def best_total(period)
        hget("#{hash_key}:#{period}:best", 'total').to_i
      end

      def best_timestamp(period)
        hget("#{hash_key}:#{period}:best", 'timestamp')
      end

      def current_total(period)
        hget("#{hash_key}:#{period}:current", 'total').to_i
      end

      def current_timestamp(period)
        hget("#{hash_key}:#{period}:current", 'timestamp')
      end

      def increment
        return if @periods.empty?

        @periods.each do |period|
          # TODO: subclass counter (or somethin) and add hincrby/etc helpers
          _current_timestamp = current_timestamp(period)
          _current_total     = current_total(period)

          if period.timestamp != _current_timestamp
            # changing current period
            hset("#{hash_key}:#{period}:current", 'total', 1)
            hset("#{hash_key}:#{period}:current", 'timestamp', period.timestamp)

            if best_total(period) < _current_total
              hset("#{hash_key}:#{period}:best", 'total', _current_total)
              hset("#{hash_key}:#{period}:best", 'timestamp', _current_timestamp)
            end
          else
            hincrby("#{hash_key}:#{period}:current", 'total', 1)
          end
        end
      end

      def count(period)
        _current_timestamp = current_timestamp(period)
        _current_total     = current_total(period)
        _best_timestamp    = best_timestamp(period)
        _best_total        = best_total(period)

        if _current_total > _best_total
          { _current_timestamp => _current_total }
        else
          { _best_timestamp => _best_total }
        end
      end

    end
  end
end