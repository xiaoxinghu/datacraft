module Bricker
  # for normalizing blocks
  class CompatiableProc < Proc
    alias_method :run, :call
    alias_method :process, :call
    alias_method :tweak, :call
  end

  # common registry
  class Registry
    def initialize
      @items = []
    end

    def mandatory_methods
      []
    end

    def <<(val)
      klass = val[:klass]
      block = val[:block]
      if klass
        fail "#{klass.name} needs to implement methods: "\
          "#{mandatory_methods}" unless valid? klass
        @items << val[:klass].new(*val[:args])
      elsif block
        @items << CompatiableProc.new(&block)
      else
        fail 'registry error'
      end
    end

    def valid?(klass)
      mandatory_methods.all? do |m|
        klass.method_defined? m
      end
    end

    def each
      @items.each do |item|
        yield item
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
      [:<<, :close]
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
