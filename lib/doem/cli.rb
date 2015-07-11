require 'doem'

module Doem
  # command line interface
  class Cli < Thor
    desc 'build [INSTRUCTION_FILE]', 'build data by instruction'
    def build(filename)
      instruction = Instruction.from_file filename
      Doem.run instruction
    end
  end
end
