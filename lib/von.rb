require 'redis'
require 'active_support/time'

require 'von/config'
require 'von/counter'
require 'von/model_counter'
require 'von/period'
require 'von/version'

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
  rescue Redis::BaseError => e
    raise e if config.raise_connection_errors
  end

  def self.count(field, period = nil)
    Counter.count(field, period)
  rescue Redis::BaseError => e
    raise e if config.raise_connection_errors
  end

  config.init!
end