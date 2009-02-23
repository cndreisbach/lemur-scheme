module Lemur
  class Lambda
    def initialize(env, forms, params, *code)
      @env = env
      @forms = forms
      @params = params.to_array
      @code = code
    end
    
    def call(*args)
      raise "Expected #{@params.size} arguments" unless args.size == @params.size
      localenv = Environment.new(@env)
      localforms = Environment.new(@forms)
      @params.zip(args).each do |sym, value|
        localenv.define(sym, value)
      end
      @code.map { |c| c.lispeval(localenv, localforms) }.last
    end
    
    def to_scm
      "(lambda #{@params.to_scm} #{@code.map {|x| x.to_scm}.join(' ')})"
    end
    
    def to_proc
      return lambda { |*args| self.call(*args) }
    end
  end
end
