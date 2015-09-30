require 'yaml'

class TestReportBuilder
  def initialize(output_file)
    @output_file = output_file
    @total_employee = 0
    @total_age = 0
  end

  def <<(row)
    @total_employee += 1
    @total_age += row[:age].to_i
  end

  def build
    report = {
      total: @total_employee,
      average_age: @total_age / @total_employee
    }
    File.open(@output_file, 'w') do |f|
      f.puts report.to_yaml
    end
  end
end
