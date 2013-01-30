require 'yaml'

module Von
  module Config
    extend self

    attr_accessor :namespace
    attr_accessor :raise_connection_errors
    attr_accessor :yearly_format
    attr_accessor :monthly_format
    attr_accessor :weekly_format
    attr_accessor :daily_format
    attr_accessor :hourly_format
    attr_accessor :minutely_format

    attr_reader  :periods
    attr_reader  :bests

    def init!
      @periods         = {}
      @bests           = {}
      @totals          = {}
      # all keys are prefixed with this namespace
      self.namespace = 'von'
      # rescue Redis connection errors
      self.raise_connection_errors = false
      # 2013
      self.yearly_format   = '%Y'
      # 2013-01
      self.monthly_format  = '%Y-%m'
      # 2013-01-02
      self.weekly_format   = '%Y-%m-%d'
      # 2013-01-02
      self.daily_format    = '%Y-%m-%d'
      # 2013-01-02 12:00
      self.hourly_format   = '%Y-%m-%d %H:00'
      # 2013-01-02 12:05
      self.minutely_format = '%Y-%m-%d %H:%M'
    end

    # Set the Redis connection to use
    #
    # arg - A Redis connection or a Hash of Redis connection options
    #
    # Returns the Redis client
    def redis=(arg)
      if arg.is_a? Redis
        @redis = arg
      else
        @redis = Redis.new(arg)
      end
    end

    # Returns the Redis connection
    def redis
      @redis ||= Redis.new
    end

    # Configure options for given Counter. Configures length of given time period
    # and any other options for the Counter
    def counter(field, options = {})
      field = field.to_sym
      options.each do |option, value|
        set_period(field, option, value) if Period.exists?(option)
        set_best(field, value) if option == :best
      end
    end

    # Returns a True if a Period is defined for the
    # given period identifier and the period has a length
    # False if not
    def period_defined_for?(key, period)
      @periods.has_key?(key) && @periods[key].has_key?(period)
    end

    private

    def set_period(field, period, length)
      @periods[field] ||= {}
      @periods[field][period.to_sym] = Period.new(period, length)
    end

    def set_best(field, time_unit)
      @bests[field] = [ time_unit ].flatten.map { |u|
        Period.new(u)
      }
    end


  end
end
