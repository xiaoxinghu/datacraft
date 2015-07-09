module Bricker
  # Building Instruction
  class BuildingInstruction
    def initialize
    end

    def pre_build_hooks
      @pre_build_hooks ||= []
    end

    def providers
      @providers ||= []
    end

    def tweakers
      @tweakers ||= []
    end

    def consumers
      @consumers ||= []
    end

    def post_build_hooks
      @post_build_hooks ||= []
    end

    def pre_build(&block)
      pre_build_hooks << { block: block }
    end

    def from(klass, *initialization_params)
      providers << { klass: klass, args: initialization_params }
    end

    def tweak(klass = nil, *initialization_params, &block)
      tweakers << { klass: klass, args: initialization_params, block: block }
    end

    def to(klass, *initialization_params)
      consumers << { klass: klass, args: initialization_params }
    end

    def post_build(&block)
      post_build_hooks << { block: block }
    end

    def self.from_file(filename)
      script_content = IO.read(filename)
      instruction = Instruction.new
      instruction.instance_eval(script_content)
    end
  end
end
