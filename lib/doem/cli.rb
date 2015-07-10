require 'doem'

module Doem
  # command line interface
  class Cli
    def self.run(args)
      unless args.size == 1
        puts 'Syntax: brick your-script.rb'
        exit(-1)
      end
      filename = args[0]
      instruction = Instruction.from_file filename
      Doem.run instruction
    end
  end
end
