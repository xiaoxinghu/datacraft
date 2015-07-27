module Datacraft
  class Context
    def providers
      @providers ||= ProviderRegistry.new
    end

    def consumers
      @consumers ||= ConsumerRegistry.new
    end

    def tweakers
      @tweakers ||= TweakerRegistry.new
    end

    def pre_hooks
      @pre_hooks ||= HookRegistry.new
    end

    def post_hooks
      @post_hooks ||= HookRegistry.new
    end

    def options
      @options ||= {}
    end
  end
end
