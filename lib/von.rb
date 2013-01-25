require 'von/config'
require 'von/counter'
require 'von/period'
require 'von/version'

require 'redis'
require 'active_support/time'

module Von
  def self.connection
    @connection ||= Redis.current
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
    counter.periods.each { |key, period| counter.increment(period) }
  end

  def self.count(field, period = nil)
    counter = Counter.new(field)
    counter.count(period)
  end

end