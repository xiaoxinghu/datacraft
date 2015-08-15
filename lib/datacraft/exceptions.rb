module Datacraft
  class InvalidInstruction < StandardError; end
  class InvalidSource < InvalidInstruction; end
  class InvalidConsumer < InvalidInstruction; end
  class InvalidTweaker < InvalidInstruction; end
  class InvalidHook < InvalidInstruction; end
end
