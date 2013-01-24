require 'von/config'
require 'von/period'
require 'von/version'

require 'active_support/all'
require 'redis'

module Von
  def self.connection
    @connection ||= Redis.current
  end

  def self.config
    Config
  end

  def self.increment(counter)
    periods = config.counter_periods(counter)

    connection.hincrby("#{config.namespace}:#{counter}", 'all', 1)

    periods.each do |period, length|
      period = Period.new(counter, period)
      connection.hincrby(period.hash, period.key, 1)
      connection.rpush(period.list, period.key) unless connection.lrange(period.list, 0, -1).include?(period.key)

      if connection.llen(period.list) > length
        expired_counter = connection.lpop(period.list)
        connection.hdel(period.hash, expired_counter)
      end
    end

    increment_parents(counter) if counter =~ /:[^:]+\z/
  end

  def self.increment_parents(counter)
    parents = counter.sub(/:[^:]+\z/, '')

    until parents.empty? do
      connection.hincrby("#{config.namespace}:#{parents}", 'all', 1)
      parents.sub!(/:?[^:]+\z/, '')
    end
  end

  def self.count(counter, period = nil)
    if period.nil?
      connection.hget("#{config.namespace}:#{counter}", 'all')
    else
      count   = []
      _period  = Period.new(counter, period)
      length  = config.counter_periods(counter)[period.to_sym]
      now     = DateTime.now.beginning_of_hour

      length.times do
        this_period = now.strftime(_period.format)
        count.unshift(this_period)
        now = _period.time_unit == :hour ? now.ago(3600) : now.send(:"prev_#{_period.time_unit}")
      end

      counter = "#{config.namespace}:#{counter}:#{period}"
      keys    = connection.hgetall(counter)
      count.map { |date| { date => keys.fetch(date, 0) }}
    end
  end

end