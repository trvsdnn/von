# Von [![Build Status](https://travis-ci.org/blahed/von.png?branch=master)](https://travis-ci.org/blahed/von)

Von is an opinionated Redis stats tracker. It works with keys, you choose one, Von increments it. It has a few built in conveniences:

## Requirements

Von uses Redis for storing counters so you'll need it get going. If you're on OS X you can use homebrew:

```bash
$ brew install redis
```

## Auto Incrementing Parent Keys

Keys are namespaced and every parent key is incremented when you increment a child key, for example:

```ruby
Von.increment('downloads')          # bumps the 'downloads' key 1 time
Von.increment('downloads:app123')   # bumps the 'downloads:app123' key 1 time AND the 'downloads' key 1 time
```

## Tracking Time Periods

By default Von will only bump a "total" counter for the given key. This is great, but what makes Von really useful is that it can be configured to group certain keys by hour, day, week, month, and year. And you can set limits on how many of each you want to keep around. Here's how it works:

### Configuring Time Periods
```ruby
Von.configure do |config|
    # Keep daily stats for 30 days
    config.counter 'downloads', :daily => 30

    # Keep monthly stats for 3 months and yearly stats for 2 years
    config.counter 'uploads', :monthly => 3, :yearly => 2
end
```

## Tracking "Bests"

Time periods are pretty cool, but sometimes you wanna know when you did your best. You can track these with Von as well:

```ruby
Von.configure do |config|
    # Track the best day for downloads
    config.counter 'downloads', :best => :day

    # Track the best hour and week for page-views
    config.counter 'page-views', :best => [ :hour, :week ]
end
```

### Incrementing

Once you've configured the keys you don't have to do anything special, just increment the key, Von will handle this rest.

```ruby
Von.increment('downloads')
Von.increment('uploads')
Von.increment('page-views')
```

## Getting Stats

```ruby
# get the total downloads (returns an Integer)
Von.count('downloads')             #=> 4
# get the monthly counts (returns an Array of Hashes)
Von.count('uploads').per(:month)   #=> [ { '2012-03' => 3 }, { '2013-04' => 1 }, { '2013-05' => 0 }]
# get the best day for downloads (returns a Hash)
Von.count('downloads').best(:day)  #=> { '2012-03-01' => 10 }

```

One nice thing to note, if you're counting a time period and there wasn't a value stored for the particular hour/day/week/etc, it'll be populated with a zero, this ensures that if you want 30 days of stats, you get 30 days of stats.

## Configuration

There are a few things you might want to configure in Von, you can do this in the configure block where you would also set time periods and expirations.

```ruby
Von.configure do |config|
    # set the Redis connection to an already existing connection
    config.redis = Redis.current
    # Initialize a new Redis connection given options
    config.redis = { :host => 'localhost', :port => 6379 }
    
    # rescue Redis connection errors
    # if the connection fails, no errors are raised by default
    config.raise_connection_errors = false

    # set the top level Redis key namespace
    config.namespace = 'von'

    # set the various formatting for time periods (defaults shown)
    config.yearly_format  = '%Y'
    config.monthly_format = '%Y-%m'
    config.weekly_format  = '%Y-%m-%d'
    config.daily_format   = '%Y-%m-%d'
    config.hourly_format  = '%Y-%m-%d %H:00'
end
```

## Installation

Add this line to your application's Gemfile:

    gem 'von'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install von

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
