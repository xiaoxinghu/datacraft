require 'forwardable'

module Datacraft
  # for normalizing blocks
  class CompatiableProc < Proc
    alias_method :run, :call
    alias_method :process, :call
    alias_method :tweak, :call
  end

  # common registry
  class Registry
    extend Forwardable
    def_delegators :instances, :each, :map
    def initialize
      @items = []
    end

    attr_accessor :mandatory_methods

    def instances
      @instances ||= @items.map do |i|
        if i[:klass]
          i[:klass].new(*i[:args])
        elsif i[:block]
          CompatiableProc.new(&i[:block])
        end
      end
    end

    def <<(val)
      klass = val[:klass]
      block = val[:block]
      if klass
        fail InvalidInstruction, "#{klass.name} needs to implement methods: "\
          "#{mandatory_methods}" unless valid? klass
      elsif block
      else
        fail 'registry error'
      end
      @items << val
    end

    def valid?(klass)
      mandatory_methods.all? do |m|
        klass.method_defined? m
      end
    end
  end

  class ProviderRegistry < Registry
    def mandatory_methods
      [:each]
    end
  end

  class ConsumerRegistry < Registry
    def mandatory_methods
      [:<<]
    end
  end

  class TweakerRegistry < Registry
    def mandatory_methods
      [:tweak]
    end
  end

  class HookRegistry < Registry
    def mandatory_methods
      [:run]
    end
  end
end
