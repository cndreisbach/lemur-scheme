#!/usr/bin/env ruby

$:.push(File.dirname(__FILE__))
LEMUR_HOME = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'rubygems'
require 'sexp'

%w(cons env lambda parser interpreter).each do |lib|
  require "lemur/#{lib}"
end

module Lemur
  
  SCHEME_BUILTINS = File.join(LEMUR_HOME, 'lib', 'builtins.scm')
  TRUE_SYM = '#t'.to_sym
  FALSE_SYM = '#f'.to_sym

  DEFAULTS = {
    FALSE_SYM => false,
    TRUE_SYM => false,
    :else => true,
    :+ => lambda { |*args| args.inject { |x, y| x + y } },
    :- => lambda { |*args| args.inject { |x, y| x - y } },
    :* => lambda { |*args| args.inject { |x, y| x * y } },
    :"/" => lambda { |*args| args.inject { |x, y| x / y } },
    :atom? => lambda { |x| x.atom? },
    :eq? => lambda { |x, y| x.eql?(y) },
    :list => lambda { |*args| Cons.from_a(args) },
    :print => lambda { |*args| puts *args.map { |a| a.to_scm } },
    :cons => lambda { |car, cdr| Cons.new(car, cdr) }
  }

  FORMS = {
    :begin => lambda { |env, forms, *code| 
      code.map { |c| c.lispeval(env, forms) }.last
    },
    :define => lambda { |env, forms, sym, *values|
      if sym.is_a?(Cons)
        env.define(sym.car, Lambda.new(env, forms, sym.cdr, *values))
      else
        env.define(sym, values.map { |v| v.lispeval(env, forms) }.last)
      end
    },    
    :set! => lambda { |env, forms, sym, value| 
      env.set!(sym, value.lispeval(env, forms))
    },
    :eval => lambda { |env, forms, *code| 
      code.map { |c| c.lispeval(env, forms) }.map { |c| c.lispeval(env, forms) }.last
    },
    :quote => lambda { |env, forms, exp| exp },
    :unquote => lambda { |env, forms, exp| exp.lispeval(env, forms) },
    :quasiquote => lambda { |env, forms, exp|
      if exp.atom?
        exp
      else
        if exp.car == :unquote
          FORMS[:unquote][env, forms, exp]  
        else
          exp.to_array.map { |elem| FORMS[:quasiquote][env, forms, elem] }.to_list
        end
      end
    },
    :lambda => lambda { |env, forms, params, *code|
      Lambda.new(env, forms, params, *code)
    },
    :and => lambda { |env, forms, *code|
      code.inject(true) { |result, c|
        (result != false) ? c.lispeval(env, forms) : false
      }
    },
    :or => lambda { |env, forms, *code| 
      code.inject(false) { |result, c|
        (result != true) ? c.lispeval(env, forms) : result
      }
    },
    :if => lambda { |env, forms, cond, *code|
      raise "Too many clause in if" if code.length > 2
      xthen, xelse = *code
      if cond.lispeval(env, forms)
        xthen.lispeval(env, forms)
      else
        xelse.nil? ? false : xelse.lispeval(env, forms)
      end
    },
    :cond => lambda { |env, forms, *code|
      passed = false
      result = false
      
      code.each do |c|
        if passed == false && c.car.lispeval(env, forms) != false
          passed = true
          result = c.cdr.car.lispeval(env, forms)
        end
      end
      
      result
    },
    :defmacro => lambda { |env, forms, name, exp|
      func = exp.lispeval(env, forms)
      forms.define(name, lambda { |env2, forms2, *rest| 
                     func.call(*rest).lispeval(env, forms)
                   })
      name
    },
    :ruby => lambda { |env, forms, *names| 
      names.inject(Kernel) { |mod, name| mod.const_get(name) }
    },
    %s[!] => lambda { |env, forms, object, message, *params|
      evaled_params = params.map { |p| p.lispeval(env, forms).to_array }
      proc = evaled_params.last.kind_of?(Lambda) ? evaled_params.pop : nil
      object.lispeval(env, forms).send(message, *evaled_params, &proc).to_list
    }
  }
  
  module ObjectExtensions
    def lispeval(env, forms)
      self
    end
    
    def to_array
      self
    end
    
    def to_list
      self
    end

    def list?
      false
    end
    
    def pair?
      false
    end
    
    def atom?
      !pair?
    end

    alias :to_scm :to_sexp
  end

  module NilExtensions
    def to_array
      []
    end

    def to_scm
      '()'
    end
    
    def list?
      true
    end
    
    def atom?
      true
    end
  end
  
  module ArrayExtensions
    def to_list
      map { |x| x.to_list }.reverse.inject(nil) { |cdr, car| Cons.new(car, cdr) }
    end

    def to_scm
      '(' + map { |x| x.to_scm }.join(' ') + ')'
    end
  end
  
  module SymbolExtensions
    def lispeval(env, forms)
      env.lookup(self)
    end
    
    def to_scm
      self.to_s
    end
  end
  
  module TrueExtensions
    def to_scm
      TRUE_SYM
    end
  end
  
  module FalseExtensions
    def to_scm
      FALSE_SYM
    end
  end
  
  module RationalExtensions
    def to_scm
      "%d/%d" % [numerator, denominator]
    end
  end
end

Object.send(:include, Lemur::ObjectExtensions)
NilClass.send(:include, Lemur::NilExtensions)
Symbol.send(:include, Lemur::SymbolExtensions)
Array.send(:include, Lemur::ArrayExtensions)
TrueClass.send(:include, Lemur::TrueExtensions)
FalseClass.send(:include, Lemur::FalseExtensions)
Rational.send(:include, Lemur::RationalExtensions)

if $0 == __FILE__
  int = Lemur::Interpreter.new
  if ARGV.empty?
    int.repl
  else
    ARGV.each do |file|
      int.eval File.read(file)
    end
  end
end
