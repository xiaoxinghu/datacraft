module Datacraft
  # define the context of the instruction
  module Context
    def sources
      @sources ||= []
    end

    def tweakers
      @tweakers ||= []
    end

    def pre_hooks
      @pre_hooks ||= []
    end

    def post_hooks
      @post_hooks ||= []
    end

    def consumers
      @consumers ||= []
    end

    def options
      @options ||= {}
    end

    def validate
      fail InvalidInstruction, "Please define data source with keyword 'from'." unless sources.size > 0
      fail InvalidInstruction, "Please define data consumer with keyword 'to'." unless consumers.size > 0
      sources.each(&:validate)
      consumers.each(&:validate)
      tweakers.each(&:validate)
      pre_hooks.each(&:validate)
      post_hooks.each(&:validate)
    end
  end
end
