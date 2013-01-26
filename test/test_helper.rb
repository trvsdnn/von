$LOAD_PATH.unshift(File.expand_path('../../test', __FILE__))

require 'rubygems'
require 'bundler'
Bundler.setup

require 'minitest/autorun'
require 'minitest/pride'
require 'mocha'
require 'timecop'

require 'von'

module Von
  class TestConnection
    attr_reader :store

    def initialize
      @store = {}
    end

    def hincrby(hash, key, counter)
      @store[hash] ||= {}

      if @store[hash].has_key?(key)
        @store[hash][key] += counter
      else
        @store[hash][key] = counter
      end

       @store[hash][key]
    end

    def hget(hash, key)
      @store[hash][key]
    end

    def hgetall(hash)
      @store.fetch(hash, {})
    end

    def hdel(hash, key)
      @store[hash].delete(key)
    end

    def rpush(list, member)
      @store[list] ||= []
      @store[list] << member
    end

    def lpop(list)
      @store[list].shift
    end

    def lrange(list, start, stop)
      @store[list] ||= []
      @store[list][start..stop]
    end

    def llen(list)
      @store[list].length
    end

  end
end

module MiniTest::Expectations
  def mock_connection!
    connection = Von::TestConnection.new
    @store     = connection.store
    Von.expects(:connection).returns(connection).at_least_once
  end
end