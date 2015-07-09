module Bricker
  class AliasingProc < Proc
    alias_method :process, :call
  end
  # this is the builder
  module Runner
    def run(instruction)
      instantiate_all(instruction.pre_build_hooks).each(&:call)
      process_rows(
        instantiate_all(instruction.providers),
        instantiate_all(instruction.tweakers),
        instantiate_all(instruction.consumers)
      )
      instantiate_all(instruction.post_build_hooks).each(&:call)
    end

    def process_rows(providers, tweakers, consumers)
      providers.each do |provider|
        provider.each do |row|
          tweakers.each do |tweaker|
            row = tweaker.process row
            break unless row
          end
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
      consumers.each(&:close)
    end

    def instantiate_all(definitions)
      definitions.map do |definition|
        instantiate(
          *definition.values_at(:klass, :args, :block)
        )
      end
    end

    def instantiate(klass, args, block)
      if klass
        klass.new(*args)
      elsif block
        AliasingProc.new(&block)
      else
        fail 'Class and block form cannot be used together at the moment'
      end
    end
  end
end
