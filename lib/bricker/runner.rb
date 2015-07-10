module Bricker
  # The runner for the whole process
  module Runner
    def run(instruction)
      context = instruction.context
      context.pre_hooks.each(&:call)
      process_rows(
        context.providers,
        context.tweakers,
        context.consumers
      )
      context.post_hooks.each(&:call)
    end

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
      consumers.each do |consumer|
        consumer.build if consumer.respond_to? :build
        consumer.close if consumer.respond_to? :close
      end
    end

  end
end
