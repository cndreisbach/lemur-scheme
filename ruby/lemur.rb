require 'rubygems'
require 'sexp'
require 'lemur/cons'
require 'lemur/env'
require 'lemur/lambda'
require 'lemur/interpreter'

module Lemur
  DEFAULTS = {
    :nil => :nil,
    :t => :t,
    :+ => lambda { |*args| args.inject { |x, y| x + y } },
    :- => lambda { |*args| args.inject { |x, y| x - y } },
    :* => lambda { |*args| args.inject { |x, y| x * y } },
    :"/" => lambda { |*args| args.inject { |x, y| x / y } },
    :car => lambda { |x| x.car },
    :cdr => lambda { |x| x.cdr },
    :cons => lambda { |x, y| Cons.new(x, y) },
    :atom? => lambda { |x| scheme_bool(!x.kind_of?(Cons)) },
    :eq? => lambda { |x, y| scheme_bool(x.equal?(y)) },
    :list => lambda { |*args| Cons.from_a(args) },
    :print => lambda { |*args| puts *args; :nil },
  }
  
  FORMS = {
    :quote => lambda { |env, forms, exp| exp },
    :define => lambda { |env, forms, sym, value| 
      env.define(sym, value.lispeval(env, forms))
    },
    :set! => lambda { |env, forms, sym, value| 
      env.set!(sym, value.lispeval(env, forms))
    },
    :if => lambda { |env, forms, cond, xthen, xelse|
      if cond.lispeval(env, forms) != :nil
        xthen.lispeval(env, forms)
      else
        xelse.lispeval(env, forms)
      end
    },
    :lambda => lambda { |env, forms, params, *code|
      Lambda.new(env, forms, params, *code)
    }
  }

  def self.scheme_bool(predicate)
    predicate ? :t : :nil
  end
  
  module ObjectExtensions
    def lispeval(env, forms)
      raise "lispeval not implemented for #{self.class}"
    end
    
    def consify
      self
    end

    def conslist?
      false
    end
    
    def deep_copy
      begin
        self.clone
      rescue TypeError
        self
      end
    end
  end
  
  module ArrayExtensions
    def consify
      map { |x| x.consify }.reverse.inject(:nil) { |cdr, car| Cons.new(car, cdr) }
    end
    
    def deep_copy
      copy = self.clone
      copy.each_with_index do |thing, index|
        copy[index] = thing.deep_copy
      end
    end
  end
  
  module HashExtensions
    def deep_copy
      copy = self.clone
      copy.each do |sym, val|
        copy[sym] = val.deep_copy
      end
    end
  end
  
  module SymbolExtensions
    def lispeval(env, forms)
      env.lookup(self)
    end
    
    def arrayify
      if conslist?
        []
      else
        self
      end
    end

    def conslist?
      self == :nil
    end
  end
  
  module StringExtensions
    def lispeval(env, forms)
      self
    end
  end

  module NumericExtensions
    def lispeval(env, forms)
      self
    end
  end
end

Object.send(:include, Lemur::ObjectExtensions)
Symbol.send(:include, Lemur::SymbolExtensions)
String.send(:include, Lemur::StringExtensions)
Numeric.send(:include, Lemur::NumericExtensions)
Array.send(:include, Lemur::ArrayExtensions)
Hash.send(:include, Lemur::HashExtensions)