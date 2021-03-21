require 'csv'
require 'net/http'
require 'json'

class Calculator
  SEPARATOR = ';'

  def self.prepare_data
    new.prepare_data
  end

  # this method requires file named input.csv with following content as example:
  # AT&T INC.;2.21;USD;2020-08-03 08:21;15
  def prepare_data
    data = CSV.read('input.csv', { col_sep: SEPARATOR })

    CSV.open('output.csv','wb') do |csv|
      data.each do |row|
        csv << prepare_row(row)
      end
    end

  rescue Errno::ENOENT
    puts 'No valid input.csv file present'
  end

  private

  # check what was the first working day before date, based on its weekday number
  def working_date(date)
    offset = case date.wday
      when 2..6 then 1
      when 1 then 3
      when 0 then 2
    end

    date - offset
  end

  def get_response(currency, date)
    uri = URI("http://api.nbp.pl/api/exchangerates/rates/A/#{currency}/#{date.to_s}")
    Net::HTTP.get_response(uri)
  end

  def prepare_row(row)
    name  = row[0]
    amount = row[1]
    currency = row[2]
    original_date = Date.parse(row[3])
    date = working_date(original_date)
    tax_taken_percentage = row[4]

    response = get_response(currency, date)

    if response.is_a?(Net::HTTPNotFound)
      # not found probably means public holiday, so try one working day earlier
      response = get_response(currency, working_date(date - 1))
    end

    response_body = JSON.parse(response.body)

    exchange_rate = response_body['rates']&.first['mid']

    [name, amount, currency, original_date, tax_taken_percentage, exchange_rate]
  end
end

Calculator.prepare_data