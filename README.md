# Von

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'von'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install von

## Usage
    
    # Configuration and Expiration
    Von.configure do
        # Set the redis namespace (all keys are prefixed with this)
        self.namespace      = 'forward:stats'
    
        # Set the format of monthly stored keys
        self.monthly_format = '%M %Y'
    
        # Keep daily stats for 30 days
        counter 'something:foo', :daily => 30

        # Keep monthly stats for 3 months and yearly stats for 2 years
        counter 'something', :monthly => 3, :yearly => 2
    end
    
    # Single keys
    Von.increment('something')      # bumps 'something'
    Von.increment('something:else') # bumps 'something' (total only) and 'something:else'
    Von.increment('foo')            # bumps 'foo'
    
    # Retrieving counts
    Von.count('something')         # retrieve total count
    Von.count('something', :daily) # retrieve daily count

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
