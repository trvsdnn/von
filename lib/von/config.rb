require 'yaml'

module Von
  module Config
    extend self

    attr_accessor :namespace
    attr_accessor :yearly_format
    attr_accessor :monthly_format
    attr_accessor :weekly_format
    attr_accessor :daily_format
    attr_accessor :hourly_format

    attr_reader  :periods

    def init!
      @counter_options = {}
      @periods         = {}
      # all keys are prefixed with this namespace
      self.namespace = 'von'
      # 2013
      self.yearly_format  = '%Y'
      # 2013-01
      self.monthly_format = '%Y-%m'
      # 2013-01-02
      self.weekly_format  = '%Y-%m-%d'
      # 2013-01-02
      self.daily_format   = '%Y-%m-%d'
      # 2013-01-02 12:00
      self.hourly_format  = '%Y-%m-%d %H:00'
    end

    def redis=(arg)
      if arg.is_a? Redis
        @redis = arg
      else
        @redis = Redis.new(arg)
      end
    end
    def redis
      @redis ||= Redis.new
    end

    def counter(field, options = {})
      options.each do |key, value|
        if Period::AVAILABLE_PERIODS.include?(key)
          @periods[field.to_sym] ||= {}
          @periods[field.to_sym][key.to_sym] = Period.new(field, key, value)
          options.delete(key)
        end
      end

      @counter_options[field.to_sym] = options
    end

    def period_defined_for?(key, period)
      @periods.has_key?(key) && @periods[key].has_key?(period)
    end

    # TODO: rename
    def counter_options(field)
      @counter_options[field.to_sym] ||= {}
    end

  end
end