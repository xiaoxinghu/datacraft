require 'forwardable'

module Datacraft

  # for normalizing blocks
  class CompatiableProc < Proc
    # alias_method :run, :call
    # alias_method :process, :call
    alias_method :tweak, :call
  end

  # method management
  module MethodDef
    extend Forwardable
    attr_reader :mandatory, :optional

    def def_mandatory(*methods)
      @mandatory = methods
      methods.each do |method|
        def_delegator :instance, method
      end
    end

    def def_optional(*methods)
      @optional = methods
      methods.each do |method|
        def_delegator :instance, method
      end
    end

    def validate_methods(klass)
      mandatory.each do |m|
        fail InvalidInstruction, "Class <#{klass}> missing mandatory methods: #{m}." unless klass.method_defined?(m)
      end
    end
  end

  # definition of component
  module Definition
    extend Forwardable
    def_delegator :instance, :respond_to?
    def self.included(base)
      base.extend(Forwardable)
      base.extend(MethodDef)
    end

    def initialize(d)
      @d = d
    end

    def instance
      @instance ||= create_instance
    end

    private

    def create_instance
      if @d[:klass]
        @d[:klass].new(*@d[:args])
      elsif @d[:block]
        CompatiableProc.new(&@d[:block])
      end
    end
  end

  # data source that provide data
  class Source
    include Definition
    def_mandatory :each

    def validate
      fail InvalidSource, 'Source needs to be a class.' unless @d[:klass]
      self.class.validate_methods @d[:klass]
    end
  end

  # data consumer that consume data
  class Consumer
    include Definition
    def_mandatory :<<
    def_optional :build, :close

    def validate
      fail InvalidConsumer, 'Consumer needs to be a class.' unless @d[:klass]
      self.class.validate_methods @d[:klass]
    end
  end

  # tweaking data row
  class Tweaker
    include Definition
    def_mandatory :tweak

    def validate
      self.class.validate_methods @d[:klass] if @d[:klass]
    end
  end

  # pre/post build hooks
  class Hook
    include Definition
    def_mandatory :call

    def validate
      fail InvalidHook, 'Hook has to be a block.' unless @d[:block]
    end
  end
end
