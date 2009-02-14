module Lemur
  class Cons
    attr_reader :car, :cdr
    alias :first :car
    alias :rest :cdr

    def self.from_a(array)
      array.to_list
    end

    def initialize(car, cdr)
      @car, @cdr = car, cdr
    end

    def lispeval(env, forms)
      if forms.respond_to?(:defined?) and forms.defined?(car)
        forms.lookup(car).call(env, forms, *cdr.arrayify)
      else
        car.lispeval(env, forms).call(*cdr.arrayify.map { |x| x.lispeval(env, forms) })
      end
    end

    def arrayify
      if list?
        [car] + cdr.arrayify
      else
        self
      end
    end

    def list?
      cdr.list?
    end
    
    def to_scm
      if list?
        "(#{arrayify.map {|x| x.to_scm}.join(' ')})"
      else
        "(cons #{car.to_scm} #{cdr.to_scm})"
      end
    end
  end
end
