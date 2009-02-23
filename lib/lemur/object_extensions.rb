module Lemur
  module ObjectExtensions
    def pair?
      false
    end
    
    def atom?
      !pair?
    end

    def scm_eval(env, forms)
      self
    end

    def to_scm
      self.to_s
    end

    # The following are convenience methods to make passing
    # S-expressions between Ruby and Scheme easier.
    def to_cons; self; end
    def to_array; self; end
  end

  module NilExtensions
    def list?
      true
    end

    def to_array
      []
    end
    
    def to_scm
      '()'
    end  
  end

  module TrueExtensions
    def to_scm
      '#t'
    end
  end

  module FalseExtensions
    def to_scm
      '#f'
    end
  end

  module SymbolExtensions
    def scm_eval(env, forms)
      env.lookup(self)
    end    
  end

  module ArrayExtensions
    def to_cons
      map { |x| x.to_cons }.reverse.inject(nil) { |cdr, car|
        Cons.new(car, cdr)
      }
    end

    def to_scm
      '(' + map { |x| x.to_scm }.join(' ') + ')'
    end
  end

end

Object.send(:include, Lemur::ObjectExtensions)
NilClass.send(:include, Lemur::NilExtensions)
Symbol.send(:include, Lemur::SymbolExtensions)
Array.send(:include, Lemur::ArrayExtensions)
TrueClass.send(:include, Lemur::TrueExtensions)
FalseClass.send(:include, Lemur::FalseExtensions)

