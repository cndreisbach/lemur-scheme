module Lemur
  class Env
    def initialize(parent=nil, defaults={})
      @parent = parent
      @defs = defaults
    end

    def define(symbol, value)
      raise "#{symbol} already defined" if self.defined?(symbol)
      set!(symbol, value)
    end

    def defined?(symbol)
      @defs.has_key?(symbol) or (@parent and @parent.defined?(symbol))
    end

    def lookup(symbol)
      begin
        return (@defs[symbol] || @parent.lookup(symbol))
      rescue NoMethodError
        raise "No value for symbol #{symbol}"
      end
    end

    def set!(symbol, value)
      @defs[symbol] = value
    end    
  end
end