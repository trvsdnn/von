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

    def reset!
      @counter_options = {}

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

    def counter(key, options = {})
      @counter_options[key] = options
    end

    def counter_options(counter)
      @counter_options[counter] ||= {}
    end

    def counter_periods(counter)
      counter_options(counter).select do |k|
        Period::AVAILABLE_PERIODS.include?(k)
      end
    end

    def from_hash!(attributes_hash = {})
      return if attributes_hash.empty?

      attributes_hash.each do |key, value|
        send(:"#{key}=", value)
      end
    end

    def configure(&block)
      instance_eval &block
    end

  end
end