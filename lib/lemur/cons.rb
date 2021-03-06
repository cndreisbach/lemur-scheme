module Lemur
  class Cons
    attr_reader :car, :cdr

    def self.from_a(array)
      array.to_cons
    end

    def initialize(car, cdr)
      @car, @cdr = car, cdr
    end
    
    def eql?(other)
      (self.class == other.class) && car.eql?(other.car) && cdr.eql?(other.cdr)
    end

    def scm_eval(env)
      if FORMS.has_key?(car)
        FORMS[car].call(env, *cdr.to_array)
      else
        car.scm_eval(env).call(*cdr.to_array.map { |x| x.scm_eval(env) })
      end
    end

    def to_array
      if list?
        [car] + cdr.to_array
      else
        self
      end
    end

    def pair?
      true
    end

    def list?
      cdr.respond_to?(:list?) && cdr.list?
    end
    
    def to_scm
      if list?
        "(#{to_array.map {|x| x.to_scm}.join(' ')})"
      else
        "(cons #{car.to_scm} #{cdr.to_scm})"
      end
    end
  end
end
