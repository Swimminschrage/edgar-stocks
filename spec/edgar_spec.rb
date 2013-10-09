require 'spec_helper'
require_relative '../lib/edgar'

describe 'Edgar' do
  let(:stock) {Edgar::Edgar.new('INTU')}
  let(:firstday) {DateTime.new(2013,10,1)}
  let(:weekend_day) {DateTime.new(2013,9,21)}
  subject {stock}

  it 'should have a reference to the symbol' do
    expect(stock.symbol).to eq('INTU')
  end

  it 'should be able to lookup valid stock symbols' do
    expect{Edgar::Edgar.new('INTU')}.to_not raise_error Edgar::InvalidSymbolError
  end

  it 'should not be able to lookup invalid stock symbols' do
    expect{Edgar::Edgar.new('LALALALALA')}.to raise_error(Edgar::InvalidSymbolError)
  end

  it 'can get closing price for October 1, 2013' do
    expect(stock.closing_price(firstday)).to eq(66.45)
  end

  it 'can get the opening price for October 1, 2013' do
    expect(stock.opening_price(firstday)).to eq(66.53)
  end

  it 'can get the high price for October 1, 2013' do
    expect(stock.high_price(firstday)).to eq(67.09)
  end

  it 'can get the low price for a stock' do
    expect(stock.low_price(firstday)).to eq(66.19)
  end

  it 'can get the volume traded for a stock' do
    expect(stock.volume(firstday)).to eq(2095700)
  end

  describe 'when configured to look to the next day' do
    before (:all) do
      Edgar::Edgar.configure({:lookup_offset => 1})
    end

    it 'should go to monday when a weekend date is specified' do
      expect(stock.opening_price(weekend_day)).to eq(66.59)
    end
  end

  describe 'when configured to look to the prev day' do
    before (:all) do
      Edgar::Edgar.configure({:lookup_offset => -1})
    end

    it 'should go to friday when a weekend date is specified' do
      expect(stock.opening_price(weekend_day)).to eq(66.64)
    end
  end

  describe 'when a future date is provided' do
    let(:future_day) {DateTime.new(2020,1,1)}
    it 'should return nil' do
      expect(stock.opening_price(future_day)).to be_nil
    end
  end

  describe 'when an old date is provided' do
    let(:past_day) {DateTime.new(1919,1,1)}
    it 'should return nil' do
      expect(stock.opening_price(past_day)).to be_nil
    end
  end

  describe 'when providing a range' do
    let(:firstday) {DateTime.new(2013, 9, 27)}
    it 'should return the running avg for opening price' do
      expect(stock.opening_price(firstday, 10)).to eq(66.28)
    end

    describe 'and rounding to 4 decimal points' do
      it 'should return the running avg to 4 decimal points' do
        Edgar::Edgar.configure({:round_to => 4})
        expect(stock.opening_price(firstday, 10)).to eq(66.278)
      end

      it 'should return the running avg to 0 decimal points' do
        Edgar::Edgar.configure({:round_to => 0})
        expect(stock.opening_price(firstday, 10)).to eq(66)
      end

      it 'should return the running avg to 3 decimal points' do
        Edgar::Edgar.configure({:round_to => 3})
        expect(stock.opening_price(firstday, 10)).to eq(66.278)
      end
    end
  end

end