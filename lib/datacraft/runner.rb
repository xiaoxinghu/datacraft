require 'benchmark'

module Datacraft
  # The runner for the whole process
  module Runner
    # run the instruction
    def run(instruction)
      @context = instruction.context
      measurements = []
      measurements << Benchmark.measure('pre build:') do
        @context.pre_hooks.each(&:call)
      end
      measurements << Benchmark.measure('process rows:') do
        @context.options[:parallel] ? pprocess_rows : process_rows
      end

      measurements << Benchmark.measure('build:') do
        build @context.consumers
      end

      measurements << Benchmark.measure('post build:') do
        @context.post_hooks.each(&:call)
      end
      report measurements if @context.options[:benchmark]
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
    def process_rows
      @context.providers.each do |provider|
        provider.each do |row|
          process row
        end
      end
    end

    # tweak & consume one row
    def process(row)
      @context.tweakers.each do |tweaker|
        row = tweaker.tweak row
        return nil unless row
      end
      @context.consumers.each do |consumer|
        consumer << row
      end
    end

    # process rows in parallel
    def pprocess_rows
      thread_number = [@context.providers.size,
                       @context.options[:n_threads]].min
      queue = Queue.new
      @context.providers.each { |p| queue << p }
      threads = thread_number.times.map do
        Thread.new do
          until queue.empty?
            p = queue.pop(true)
            p.each { |row| process row }
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
