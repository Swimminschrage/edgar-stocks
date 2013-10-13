# Edgar-Stocks
[![Gem Version](https://badge.fury.io/rb/edgar-stocks.png)](http://badge.fury.io/rb/edgar-stocks)

Edgar-Stocks is a Ruby gem that provides access to historical stock data in a simple, configurable way.

Edgar provides the following info for a stock:
- Opening price
- Closing price
- Daily high
- Daily low
- Adjusted close
- Volume

In addition to the above, Edgar can calculate the rolling average for a given date for a particular stock.

Have more ideas how I can improve the gem?  Leave me a message!

## Installation

Add this line to your application's Gemfile:

    gem 'edgar-stocks'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install 'edgar-stocks'

## Usage

Simply create a new Edgar object for each stock you care about:

    stock = Edgar::Edgar.new('INTU')

Then query it!

    stock.closing_price # Returns today's closing price

Or ask for a date in the past.

    stock.closing_price(DateTime.yesterday)  # Obviously get yesterday's closing price

You can even get running averages

    stock.closing_price(DateTime.now, 5)  # Get the five day average closing price starting with today's closing.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
