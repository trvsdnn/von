require 'test_helper'

describe Von do

  before :each do
    Von.config.reset!
    connection = Von::TestConnection.new
    @store     = connection.store
    Von.expects(:connection).returns(connection).at_least_once
  end

  it "increments a counter and counts it" do
    Von.increment('foo')
    Von.increment('foo')
    Von.count('foo').must_equal 2
  end

end
