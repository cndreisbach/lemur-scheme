module Lemur
  class Scope
    def initialize(parent = nil)
      @parent = parent
      @defs = {}
    end

    def define(symbol, value)
      if !@defs.has_key?(symbol) and !@parent.nil? and @parent.defined?(symbol)
        @parent.define(symbol, value)
      else
        @defs[symbol] = value
      end
    end

    # TODO give the ability to alter non-shadowed objects in their
    # home scope
    def set!(symbol, value)
      puts "Warning: setting non-allocated #{symbol}" unless self.defined?(symbol)
      define(symbol, value)
    end

    alias :[]= :set!

    def defined?(symbol)
      @defs.has_key?(symbol) or (@parent and @parent.defined?(symbol))
    end

    # TODO clean this up
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

    alias :[] :lookup

  end
end
