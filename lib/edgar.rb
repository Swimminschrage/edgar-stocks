require 'edgar/version'
require 'net/http'
require 'csv'
require 'time'

module Edgar

  class Edgar
    attr_reader :symbol

    # Configuration defaults
    @@config = {
        :lookup_offset => -1,
        :round_to => 2
    }

    @@valid_config_keys = @@config.keys

    def self.configure(opts = {})
      opts.each {|k,v| @@config[k.to_sym] = v if @@valid_config_keys.include? k.to_sym}
    end

    def self.config
      @@config
    end

    def initialize(symbol)
      @symbol = symbol

      @midnight = Date.today

      # Perform the actual lookup of historical data and parse it into arrays that
      # are cached in memory
      @data = CSV.parse(lookup)
    end

    def current_price
      lookup_daily_info 'l1'
    end

    def closing_price(date = DateTime.now, running = 1)
      return nil if date > DateTime.now
      return lookup_daily_info 'p' if date > @midnight && running == 1
      lookup_by_column(running, date, 4)
    end

    def opening_price(date = DateTime.now, running = 1)
      return nil if date > DateTime.now
      return lookup_daily_info 'o' if date > @midnight && running == 1
      lookup_by_column(running, date, 1)
    end

    def high_price(date = DateTime.now, running = 1)
      return nil if date > DateTime.now
      return lookup_daily_info 'h' if date > @midnight && running == 1
      lookup_by_column(running, date, 2)
    end

    def low_price(date = DateTime.now, running = 1)
      return nil if date > DateTime.now
      return lookup_daily_info 'g' if date > @midnight && running == 1
      lookup_by_column(running, date, 3)
    end

    def volume(date = DateTime.now, running = 1)
      return nil if date > DateTime.now
      return lookup_daily_info 'v' if date > @midnight && running == 1
      lookup_by_column(running, date, 5)
    end

    def pe_ratio
      lookup_daily_info 'r2'
    end

    private

    def lookup
      @content ||= get_historical_data
    end

    def get_historical_data
      uri = URI("http://ichart.finance.yahoo.com/table.csv?s=#{@symbol}")
      response = Net::HTTP.get_response(uri)

      raise InvalidSymbolError.new("Unable to lookup '#{@symbol}'") unless response.code == "200"
      response.body
    end

    def get_daily_data(property)
      property = [property] if property.instance_of? String

      uri = URI("http://download.finance.yahoo.com/d/quotes.csv?s=#{@symbol}&f=#{property.join('')}&e=.csv")
      response = Net::HTTP.get_response(uri)

      raise InvalidSymbolError.new("Unable to lookup '#{@symbol}'") unless response.code == '200'
      response.body
    end

    def lookup_daily_info(property)
      all_data = CSV.parse get_daily_data(property)
      all_data[0][0]
    end

    def lookup_by_column(running, date, column)
      return nil if date > DateTime.now()

      running = 1 if running < 1

      formatted_date = date.strftime('%Y-%m-%d')

      @data[1..@data.size].each_index do |index|
        row = @data[index+1]

        return sum_and_average(index+1, running, column) if row[0] == formatted_date

        if DateTime.parse(row[0]) < date
          if Edgar.config[:lookup_offset] < 0
            return sum_and_average(index+1, running, column)
          else
            return sum_and_average(index, running, column)
          end
        end

      end
      return nil
    end

    def sum_and_average(start, days, column)
      total = @data[start, days].inject(0) do |sum, row|
        sum + row[column.to_i].to_f
      end

      # Round off to at most two digits
      round_to = Edgar.config[:round_to]
      round_to = 2 if round_to < 0

      denom = @data[start, days].size
      (total / denom).round(round_to)
    end
  end

  class InvalidSymbolError < ArgumentError
    def initialize(message)
      @message = message
    end

    def to_s
      @message
    end
  end
end
