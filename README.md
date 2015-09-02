# Datacraft

Play with data like a Pro, and have fun like Minecraft.

[![Gem Version](https://badge.fury.io/rb/datacraft.svg)](http://badge.fury.io/rb/datacraft)
[![Build Status](https://travis-ci.org/xiaoxinghu/datacraft.svg?branch=master)](https://travis-ci.org/xiaoxinghu/datacraft)
[![Dependency Status](https://gemnasium.com/xiaoxinghu/datacraft.svg)](https://gemnasium.com/xiaoxinghu/datacraft)
[![Code Climate](https://codeclimate.com/github/xiaoxinghu/datacraft/badges/gpa.svg)](https://codeclimate.com/github/xiaoxinghu/datacraft)

## what is it

`Datacraft` is an ETL tool highly inspired by open source project [kiba](https://github.com/thbar/kiba). But we need certain advanced features which current kiba does not provide, so we decided to roll out our own version. Here are the major ones are already implemented:

- build action after loading data (explained later)
- parallel processing
- lazy initialization

And we need more. Here are some ideas bouncing around in my head and might become new features.

- data flow, pipelining
- dry run with analytic results
- snapshot the data on change points and generate report for intuitive debugging.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'datacraft'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install datacraft

## Usage

Here is an example of instruction script.

```ruby

# data source class
class CsvFile
  def initialize(csv_file)
    @csv = CSV.open(csv_file, headers: true, header_converters: :symbol)
  end

  # mandatory method for data source class.
  # Should always yield data rows.
  def each
    @csv.each do |row|
      yield(row.to_hash)
    end
    @csv.close
  end
end

# Data consumer class. Here we just output statistic
# information of the data set.
class ReportBuilder
  def initialize
    @total_employee = 0
    @total_age = 0
  end

  # mandatory method for consume data
  def <<(row)
    @total_employee += 1
    @total_age += row[:age].to_i
  end

  # optional method for build final product
  def build
    File.open('report.txt', 'w') do |f|
      f.puts "Total Employee: #{@total_employee}"
      f.puts "Total Age: #{@total_age}"
      f.puts "Average Age: #{@total_age / @total_employee}" unless @total_employee == 0
    end
  end
end

retirement_age = 60
# define data source
from CsvFile, 'employees.csv'

total_rows = 0
# tweak each row
tweak do |row|
  # eliminate the retired ones, return nil means to
  # discard the data
  total_rows += 1
  row[:age].to_i < retirement_age ? row : nil
end

# define data consumer
to ReportBuilder
```

Run the script:

```bash
$ dcraft build inst.rb
```

### parallel processing

To improve the performance of the script, you can enable multithreading by setting the option.

```ruby
set :parallel, true # default is false
set :n_threads, 4 # default 8
```

Please notice, due to [GIL](https://en.wikipedia.org/wiki/Global_Interpreter_Lock), we are not able to take advantage of multicore system with parallel processing. But when the threads are block by heavy I/O, which is very common under this circumstance, then it can make considerable performance boost.

### benchmark

Sometimes you just want to know: **why is my script so slow?** In order to efficiently spot the bottleneck of your script, you can enable `benchmark mode`.

```ruby
set :benchmark, true
```

Then run your script, you will see the detailed benchmark information.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xiaoxinghu/datacraft. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
