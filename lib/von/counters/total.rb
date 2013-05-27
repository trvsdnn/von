module Von
  module Counters
    class Total
      include Commands

      attr_reader :field

      # Initialize a new Counter
      #
      # field - counter field name
      def initialize(field)
        @field = field.to_sym
      end

      # Returns the Redis hash key used for storing counts for this Counter
      def hash_key
        "#{Von.config.namespace}:counters:#{@field}"
      end

      # Increment the total count for this Counter
      # If the key has time periods specified, increment those.
      #
      # Returns the Integer total for the key
      def increment
        hincrby(hash_key, 'total', 1).to_i
      end

      # Count the "total" field for this Counter.
      #
      # Returns an Integer count
      def count
        count = hget(hash_key, 'total')
        count.nil? ? 0 : count.to_i
      end

      # Lookup the count for this Counter in Redis.
      # If a Period argument is given we lookup the count for
      # all of the possible units (not expired), zeroing ones that
      # aren't set in Redis already.
      #
      # period - A Period to lookup
      #
      # Returns an Integer representing the count or an Array of counts.
      def self.count(field)
        Counter.new(field).count
      end

    end
  end
end
