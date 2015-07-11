require 'csv'

class CsvSource
  def initialize(filename)
    @csv = CSV.open(filename, headers: true, header_converters: :symbol)
  end

  def each
    @csv.each do |row|
      yield(row.to_hash)
    end
    @csv.close
  end
end

class Builder
  def initialize
    @total = 0
    @total_age = 0
  end
  def <<(row)
    @total += 1
    @total_age += row[:age].to_i
  end

  def build
    open('report.txt', 'w') do |f|
      f.puts "total persion: #{@total}"
      f.puts "average age: #{@total_age.to_f / @total}"
    end
  end

  def close
  end

end

pre_build do
  puts 'Building ...'
end

post_build do
  puts 'Construction complete.'
end

from CsvSource, 'data.csv'

tweak do |row|
  # puts row
  row[:email] = 'N/A' unless row[:email]
  row
end

to Builder
