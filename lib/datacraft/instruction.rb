module Datacraft
  # Building Instruction
  class Instruction
    attr_reader :context

    def initialize(context = Context.new)
      @context = context
    end

    def pre_build(&block)
      @context.pre_hooks << { block: block }
    end

    def from(klass, *initialization_params)
      @context.providers << { klass: klass, args: initialization_params }
    end

    def tweak(klass = nil, *initialization_params, &block)
      @context.tweakers << { klass: klass, args: initialization_params, block: block }
    end

    def to(klass, *initialization_params)
      @context.consumers << { klass: klass, args: initialization_params }
    end

    def post_build(&block)
      @context.post_hooks << { block: block }
    end

    def set(key, value)
      @context.options[key.to_sym] = value
    end

    def self.from_file(filename)
      script_content = IO.read(filename)
      instruction = Instruction.new
      instruction.instance_eval(script_content)
      instruction
    end

    def self.check(filename)
      begin
        script_content = IO.read(filename)
        instruction = Instruction.new
        instruction.instance_eval(script_content)
        'Looks good.'
      rescue InvalidInstruction => e
        e.message
      end
    end
  end
end
