require 'redis'
require 'active_support/time'

require 'von/config'
require 'von/period'
require 'von/counter'
require 'von/counters/commands'
require 'von/counters/total'
require 'von/counters/period'
require 'von/counters/best'
require 'von/counters/current'
require 'von/version'

module Von
  PARENT_REGEX = /:?[^:]+\z/

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
    parents = field.to_s.sub(PARENT_REGEX, '')
    total   = increment_counts_for(field)

    until parents.empty? do
      increment_counts_for(parents)
      parents.sub!(PARENT_REGEX, '')
    end

    total
  rescue Redis::BaseError => e
    raise e if config.raise_connection_errors
  end

  def self.increment_counts_for(field)
    counter = Counters::Total.new(field)
    total   = counter.increment

    if config.periods_defined_for_counter?(counter)
      periods = config.periods[counter.field]
      Counters::Period.new(counter.field, periods).increment
    end

    if config.bests_defined_for_counter?(counter)
      periods = config.bests[counter.field]
      Counters::Best.new(counter.field, periods).increment
    end

    if config.currents_defined_for_counter?(counter)
      periods = config.currents[counter.field]
      Counters::Current.new(counter.field, periods).increment
    end

    total
  end

  def self.count(field)
    Counter.new(field)
  rescue Redis::BaseError => e
    raise e if config.raise_connection_errors
  end

  config.init!
end
