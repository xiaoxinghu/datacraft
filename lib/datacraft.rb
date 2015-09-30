require 'datacraft/version'
require 'datacraft/exceptions'
require 'datacraft/definition'
require 'datacraft/context'
require 'datacraft/instruction'
require 'datacraft/parser'
require 'datacraft/runner'

module Datacraft
  extend Datacraft::Runner
  extend Datacraft::Parser
end
