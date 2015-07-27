require 'benchmark'

module Datacraft
  # The runner for the whole process
  module Runner
    # run the instruction
    def run(instruction)
      context = instruction.context
      measurements = []
      measurements << Benchmark.measure('pre build:') do
        context.pre_hooks.each(&:call)
      end
      measurements << Benchmark.measure('process rows:') do
        if context.options[:parallel]
          pprocess_rows(
            context.providers,
            context.tweakers,
            context.consumers)
        else
          process_rows(
            context.providers,
            context.tweakers,
            context.consumers)
        end
      end

      measurements << Benchmark.measure('build:') do
        build context.consumers
      end

      measurements << Benchmark.measure('post build:') do
        context.post_hooks.each(&:call)
      end
      report measurements if context.options[:benchmark]
    end

    # output benchmark results
    def report(measurements)
      width = measurements.max_by { |m| m.label.size }.label.size + 1
      puts "#{' ' * width}#{Benchmark::CAPTION}"
      measurements.each do |m|
        puts "#{m.label.to_s.ljust width} #{m}"
      end
    end

    # process rows sequentially
    def process_rows(providers, tweakers, consumers)
      providers.each do |provider|
        provider.each do |row|
          tweakers.each do |tweaker|
            row = tweaker.tweak row
            break unless row
          end
          # nil means to dismiss the row
          next unless row
          consumers.each do |consumer|
            consumer << row
          end
        end
      end
    end

    # process rows in parallel
    def pprocess_rows(providers, tweakers, consumers)
      threads = providers.map do |provider|
        Thread.new(provider) do |p|
          p.each do |row|
            tweakers.each do |tweaker|
              row = tweaker.tweak row
              break unless row
            end
            next unless row
            consumers.each do |consumer|
              consumer << row
            end
          end
        end
      end
      threads.each(&:join)
    end

    # build and close consumers
    def build(consumers)
      consumers.each do |consumer|
        consumer.build if consumer.respond_to? :build
        consumer.close if consumer.respond_to? :close
      end
    end
  end
end
