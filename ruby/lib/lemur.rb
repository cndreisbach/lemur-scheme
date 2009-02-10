#!/usr/bin/env ruby

$:.push(File.dirname(__FILE__))
LEMUR_HOME = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

require 'rubygems'
require 'sexp'
require 'lemur/cons'
require 'lemur/env'
require 'lemur/lambda'
require 'lemur/interpreter'

module Lemur

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
