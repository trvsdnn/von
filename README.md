# Von [![Build Status](https://secure.travis-ci.org/blahed/von.png)](http://travis-ci.org/blahed/von)

Von is an opinionated Redis stats tracker. It works with keys, you choose one, Von increments it. It has a few built in conveniences:

## Auto Incrementing Parent Keys

Keys are namespaced and every parent key is incremented when you increment a child key, for example:

```ruby
Von.increment('downloads')              # bumps the 'downloads' key 1 time
Von.increment('downloads:app123')       # bumps the 'downloads:app123' key 1 time AND the 'downloads' key 1 time
```

## Time Period Grouping and Limiting

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

### Incrementing Time Periods

Once you've configured the keys you want to use Time Periods on, you just increment them like normal, Von handles the rest.

```ruby
Von.increment('downloads')
Von.increment('uploads')
```

## Counting (getting the stats)

```ruby
# get the total downloads (returns an Integer)
Von.count('downloads')             #=> 4
# get the monthly counts (returns an Array of Hashes)
Von.count('downloads', :monthly)   #=> [ { '2012-03 => 3}, { '2013-04' => 1 }]

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
