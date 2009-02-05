require 'rubygems'
require 'sexp'
require 'cons'
require 'env'
require 'lispeval'

def scheme_bool(predicate)
  predicate ? :t : :nil
end
    
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
