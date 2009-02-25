module Lemur
  class Environment < Scope 
    DEFAULTS = {
      :+ => lambda { |*args| args.inject { |x, y| x + y } },
      :- => lambda { |*args| args.inject { |x, y| x - y } },
      :* => lambda { |*args| args.inject { |x, y| x * y } },
      :"/" => lambda { |*args| args.inject { |x, y| x / y } },
      :eq? => lambda { |x, y| x.eql?(y) },
      :list => lambda { |*args| Cons.from_a(args) },
      :print => lambda { |*args| puts *args.map { |a| a.to_scm } }
    }
       
    def initialize
      @defs = DEFAULTS
    end
  end
end
