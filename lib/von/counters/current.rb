module Von
  module Counters
    class Current
      include Commands

      # Initialize a new Counter
      #
      # field - counter field name
      def initialize(field, periods = nil)
        @field   = field.to_sym
        @periods = periods || []
      end

      # Returns the Redis hash key used for storing counts for this Counter
      def hash_key
        "#{Von.config.namespace}:counters:currents:#{@field}"
      end

      def current_timestamp(time_unit)
        hget("#{hash_key}:#{time_unit}", 'timestamp')
      end

      def increment(value=1, timestamp=Time.now)
        return if @periods.empty?

        @periods.each do |period|
          if period.timestamp(timestamp) != current_timestamp(period.time_unit)
            hset("#{hash_key}:#{period.time_unit}", 'total', value)
            hset("#{hash_key}:#{period.time_unit}", 'timestamp', period.timestamp(timestamp))
          else
            hincrby("#{hash_key}:#{period.time_unit}", 'total', value)
          end
        end
      end

      def count(time_unit)
        count = hget("#{hash_key}:#{time_unit}", 'total')
        count.nil? ? 0 : count.to_i
      end

    end
  end
end
