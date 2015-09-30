require_relative 'test_helper'
require_relative 'support/test_csv_source'
require_relative 'support/test_report_builder'

class TestIntegration < Datacraft::Test
  let(:input) { 'test/tmp/input.csv' }
  let(:output) { 'test/tmp/output.yml' }

  let(:sample_csv_data) do
    <<CSV
first_name,last_name,age,sex
John,Doe,25,M
Mary,Johnson,34,F
Cindy,Backgammon,88,F
Patrick,McWire,60,M
CSV
  end

  def clean
    remove_files(*Dir['test/tmp/*.csv'])
    remove_files(*Dir['test/tmp/*.yml'])
  end

  def setup
    clean
    IO.write(input, sample_csv_data)
  end

  def teardown
    clean
  end

  def test_process_csv
    instruction = Datacraft.parse do
      input_file = 'test/tmp/input.csv'
      output_file = 'test/tmp/output.yml'
      retirement_age = 60

      from TestCsvSource, input_file

      tweak do |row|
        row[:age].to_i < retirement_age ? row : nil
      end

      to TestReportBuilder, output_file
    end

    Datacraft.run instruction
    report = YAML.load_file(output)
    assert_equal 2, report[:total]
    assert_equal 29, report[:average_age]
  end
end
