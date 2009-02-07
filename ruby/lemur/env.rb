module Lemur
  class Env
    def initialize(parent=nil, defaults={})
      @parent = parent
      @defs = defaults
    end

    def define(symbol, value)
      @defs[symbol] = value
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
      if @defs.has_key?(symbol)
        @defs[symbol] = value
      else
        raise "No definition of #{symbol} to set to #{value}" if @parent.nil?
        @parent.set!(symbol, value)
      end
    end    
  end
end