module Datacraft
  # Building Instruction
  class Instruction
    include Context
    attr_reader :context

    def initialize
      options[:parallel] = false
      options[:benchmark] = false
      options[:n_threads] = 8
    end

    def pre_build(&block)
      pre_hooks << Hook.new(block: block)
    end

    def from(klass, *initialization_params)
      sources << Source.new(klass: klass, args: initialization_params)
    end

    def tweak(klass = nil, *initialization_params, &block)
      tweakers << Tweaker.new(klass: klass, args: initialization_params, block: block)
    end

    def to(klass, *initialization_params)
      consumers << Consumer.new(klass: klass, args: initialization_params)
    end

    def post_build(&block)
      post_hooks << Hook.new(block: block)
    end

    def set(key, value)
      options[key.to_sym] = value
    end

    def self.from_file(filename)
      script_content = IO.read(filename)
      instruction = Instruction.new
      instruction.instance_eval(script_content)
      instruction.validate
      instruction
    end
  end
end
