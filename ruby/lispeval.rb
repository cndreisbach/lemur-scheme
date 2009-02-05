class Object
  def lispeval(env)
    raise "lispeval not implemented for #{self.class}"
  end
end

class String
  def lispeval(env, forms)
    self
  end
end

class Numeric
  def lispeval(env, forms)
    self
  end
end

class Symbol
  def lispeval(env, forms)
    env.lookup(self)
  end
end
