require 'datacraft'

module Datacraft
  # command line interface
  class Cli < Thor
    desc 'build [INSTRUCTION_FILE]', 'build the data by instruction'
    def build(filename)
      Datacraft.run check(filename)
    end

    desc 'check [INSTRUCTION_FILE]',
         'evaluate the instruction without running it'
    def check(filename)
      begin
        script = IO.read(filename)
        instruction = Datacraft.parse script
        puts 'You are ready to go.'
        instruction
      rescue InvalidInstruction => e
        puts e
      end
    end
  end
end
