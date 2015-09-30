require 'benchmark'

module Datacraft
  # The runner for the whole process
  module Runner
    # run the instruction
    def run(instruction)
      @inst = instruction
      measurements = []

      # run pre_build hooks
      if @inst.respond_to? :pre_hooks
        measurements << Benchmark.measure('pre build:') do
          @inst.pre_hooks.each(&:call)
        end
      end

      # process the rows
      measurements << Benchmark.measure('process rows:') do
        @inst.options[:parallel] ? pprocess_rows : process_rows
      end

      # build
      measurements << Benchmark.measure('build:') do
        build @inst.consumers
      end

      # run post_build hooks
      if @inst.respond_to? :post_hooks
        measurements << Benchmark.measure('post build:') do
          @inst.post_hooks.each(&:call)
        end
      end
      report measurements if @inst.options[:benchmark]
    end

    private

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
      @inst.sources.each do |source|
        source.each do |row|
          process row
        end
      end
    end

    # tweak & consume one row
    def process(row)
      @inst.tweakers.each do |tweaker|
        row = tweaker.tweak row
        return nil unless row
      end
      @inst.consumers.each do |consumer|
        consumer << row
      end
    end

    # process rows in parallel
    def pprocess_rows
      thread_number = [@inst.sources.size,
                       @inst.options[:n_threads]].min
      queue = Queue.new
      @inst.sources.each { |p| queue << p }
      threads = thread_number.times.map do
        Thread.new do
          begin
            while p = queue.pop(true)
              p.each { |row| process row }
            end
          rescue ThreadError
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
