require 'csv'

class TestCsvSource
  def initialize(csv_file)
    @csv = CSV.open(csv_file, headers: true, header_converters: :symbol)
  end

  def each
    @csv.each do |row|
      yield(row.to_hash)
    end
    @csv.close
  end

end
