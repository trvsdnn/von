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
    Counter.increment(field)
  end

  def self.count(field, period = nil)
    Counter.count(field, period)
  end

  config.init!
end