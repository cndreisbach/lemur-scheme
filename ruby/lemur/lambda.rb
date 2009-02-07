module Lemur
  class Lambda
    def initialize(env, forms, params, *code)
      @env = env.copy
      @forms = forms
      @params = params.arrayify
      @code = code
    end
    
    def call(*args)
      raise "Expected #{@params.size} arguments" unless args.size == @params.size
      binding = Env.new(@env)
      @params.zip(args).each do |sym, value|
        binding.define(sym, value)
      end
      @code.map { |c| c.lispeval(binding, @forms) }.last
    end
    
    def to_sexp
      "(lambda #{@params.to_sexp} #{@code.map {|x| x.to_sexp}.join(' ')})"
    end
  end
end