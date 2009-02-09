#!/usr/bin/env ruby

$:.push(File.dirname(__FILE__))

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
    :eval => lambda { |env, forms, *code| 
      code.map { |c| c.lispeval(env, forms) }.map { |c| c.lispeval(env, forms) }.last
    },
    :quote => lambda { |env, forms, exp| exp },
    :define => lambda { |env, forms, sym, value| 
      env.define(sym, value.lispeval(env, forms))
    },
    :set! => lambda { |env, forms, sym, value| 
      env.set!(sym, value.lispeval(env, forms))
    },
    :lambda => lambda { |env, forms, params, *code|
      Lambda.new(env, forms, params, *code)
    },
    :if => lambda { |env, forms, cond, xthen, xelse|
      if cond.lispeval(env, forms) != :nil
        xthen.lispeval(env, forms)
      else
        xelse.lispeval(env, forms)
      end
    },
    :defmacro => lambda { |env, forms, name, exp|
      func = exp.lispeval(env, forms)
      forms.define(name, lambda { |env2, forms2, *rest| 
        func.call(*rest).lispeval(env, forms)
      })
      name
    },
    :ruby => lambda { |env, forms, name| 
      Kernel.const_get(name)
    },
    %s[!] => lambda { |env, forms, object, message, *params|
      evaled_params = params.map { |p| p.lispeval(env, forms).arrayify }
      proc = evaled_params.last.kind_of?(Lambda) ? evaled_params.pop : nil
      object.lispeval(env, forms).send(message, *evaled_params, &proc).consify
    }
  }

  def self.scheme_bool(predicate)
    predicate ? :t : :nil
  end
  
  module ObjectExtensions
    def lispeval(env, forms)
      self
    end
    
    def arrayify
      self
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
end

Object.send(:include, Lemur::ObjectExtensions)
Symbol.send(:include, Lemur::SymbolExtensions)
Array.send(:include, Lemur::ArrayExtensions)

if $0 == __FILE__
  Lemur::Interpreter.new.repl
end
