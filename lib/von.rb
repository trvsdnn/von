require 'redis'
require 'active_support/time'

require 'von/config'
require 'von/period'
require 'von/counter'
require 'von/best_counter'
require 'von/period_counter'
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
    counter = Counter.new(field)
    total   = counter.increment

    if config.periods_defined_for_counter?(counter)
      periods = config.periods[counter.field]
      PeriodCounter.new(counter.field, periods).increment
    elsif config.bests_defined_for_counter?(counter)
      periods = config.bests[counter.field]
      BestCounter.new(counter.field, periods).increment
    end

    total
  end

  # Increment the Redis count for this Counter.
  # If the key has parents, increment them as well.
  #
  # Returns the Integer total for the key
  # def self.increment(field)
  #   total   = Counter.new(field).increment
  #   parents = field.sub(PARENT_REGEX, '')
  # 
  #   until parents.empty? do
  #     Counter.new(parents).increment
  #     parents.sub!(PARENT_REGEX, '')
  #   end
  # 
  #   total
  # end

  def self.count(field, period = nil)
    if period.nil?
      Counter.new(field).count
    else
      periods = config.periods[field.to_sym]
      PeriodCounter.new(field, periods).count(period)
    end
  rescue Redis::BaseError => e
    raise e if config.raise_connection_errors
  end

  config.init!
end
