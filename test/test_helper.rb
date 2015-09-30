$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'datacraft'

require 'minitest/autorun'

module Datacraft
  class Test < Minitest::Test
    extend Minitest::Spec::DSL

    def remove_files(*files)
      files.each do |file|
        File.delete(file) if File.exist?(file)
      end
    end

  end
end
