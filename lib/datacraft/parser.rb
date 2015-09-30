module Datacraft
  module Parser
    def parse(script = nil, &block)
      instruction = Instruction.new
      if script
        instruction.instance_eval(script)
      else
        instruction.instance_eval(&block)
      end
      instruction.validate
      instruction
    end
  end
end
