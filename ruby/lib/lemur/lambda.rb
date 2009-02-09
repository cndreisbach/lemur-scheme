module Lemur
  class Lambda
    def initialize(env, forms, params, *code)
      @env = env
      @forms = forms
      @params = params.arrayify
      @code = code
    end
    
    def call(*args)
      raise "Expected #{@params.size} arguments" unless args.size == @params.size
      localenv = Env.new(@env)
      localforms = Env.new(@forms)
      @params.zip(args).each do |sym, value|
        localenv.define(sym, value)
      end
      @code.map { |c| c.lispeval(localenv, localforms) }.last
    end
    
    def to_sexp
      "(lambda #{@params.to_sexp} #{@code.map {|x| x.to_sexp}.join(' ')})"
    end
    
    def to_proc
      return lambda { |*args| self.call(*args) }
    end
  end
end