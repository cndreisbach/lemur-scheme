require 'rubygems'
require 'sexp'
require 'lemur/cons'
require 'lemur/env'
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
  
  FORMS = {}

  def self.scheme_bool(predicate)
    predicate ? :t : :nil
  end
  
  module ObjectExtensions
    def lispeval(env)
      raise "lispeval not implemented for #{self.class}"
    end
    
    def consify
      self
    end

    def conslist?
      false
    end
  end
  
  module ArrayExtensions
    def consify
      map { |x| x.consify }.reverse.inject(:nil) { |cdr, car| Cons.new(car, cdr) }
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