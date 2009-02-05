class Cons
  attr_reader :car, :cdr

  def self.from_a(array)
    array.consify
  end

  def initialize(car, cdr)
    @car, @cdr = car, cdr
  end

  def lispeval(env, forms)
    if forms.respond_to?(:defined) and forms.defined?(car)
      forms.lookup(car).call(env, forms, *cdr.arrayify)
    else
      car.lispeval(env, forms).call(*cdr.arrayify.map { |x| x.lispeval(env, forms) })
    end
  end

  def arrayify
    if conslist?
      [car] + cdr.arrayify
    else
      self
    end
  end

  def conslist?
    cdr.conslist?
  end
end

class Object
  def consify
    self
  end

  def conslist?
    false
  end
end

class Array
  def consify
    map { |x| x.consify }.reverse.inject(:nil) { |cdr, car| Cons.new(car, cdr) }
  end
end

class Symbol
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
