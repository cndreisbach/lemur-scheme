module Lemur
  class Environment < Scope
    def initialize(parent = nil, defaults = {})
      @parent = parent
      @defs = defaults
    end
  end
end
