module Lemur
  class Environment < Scope    
    def initialize
      @defs = DEFAULTS.clone
    end
  end
end
