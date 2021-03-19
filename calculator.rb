require 'csv'
require 'net/http'

class Calculator
  SEPARATOR = ';'

  def self.prepare_data
    new.prepare_data
  end

  # this method requires file named input.csv with following content as example:
  # AT&T INC.;2.21;USD;2020-08-03 08:21;15
  def prepare_data
    data = CSV.read('input.csv', { col_sep: SEPARATOR })

    data.each do |row|
      name = row[0]
      amount = row[1]
      currency = row[2]
      date = Date.parse(row[3])
      tax_taken_percentage = row[4]

      puts currency_date(date).to_s

      uri = URI("http://api.nbp.pl/api/exchangerates/rates/A/#{currency}/#{currency_date(date).to_s}")

      response = Net::HTTP.get_response(uri)

      puts response.body
    end
  end

  private

  # check what was the first working day before date, based on its weekday number
  def currency_date(date)
    offset = case date.wday
      when 2..6 then 1
      when 1 then 3
      when 0 then 2
    end

    date - offset
  end
end

Calculator.prepare_data