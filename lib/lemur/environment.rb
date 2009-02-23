module Lemur
  class Environment
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
        if @defs.has_key?(symbol)
          return @defs[symbol]
        else
          return @parent.lookup(symbol)
        end
      rescue NoMethodError
        raise "No value for symbol #{symbol}"
      end
    end

    def set!(symbol, value)
      puts "Warning: setting non-allocated #{symbol}" unless self.defined?(symbol)
      @defs[symbol] = value
    end
    
    def merge(hash)   
      @defs.merge!(hash)
    end
  end
end
