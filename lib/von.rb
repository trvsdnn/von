require 'von/config'
require 'von/counter'
require 'von/period'
require 'von/version'

require 'redis'
require 'active_support/time'

module Von
  def self.connection
    @connection ||= config.redis
  end

  def self.config
    Config
  end

  def self.configure
    yield(config)
  end

  def self.increment(field)
    counter = Counter.new(field)
    counter.increment
  end

  def self.count(field, period = nil)
    counter = Counter.new(field)
    counter.count(period)
  end

  config.init!
end