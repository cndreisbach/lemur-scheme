module Lemur
  class Lambda
    def initialize(env, params, *code)
      @env = env
      @params = params.to_array
      @code = code
    end
    
    def call(*args)
      raise "Expected #{@params.size} arguments" unless args.size == @params.size
      localenv = Scope.new(@env)
      @params.zip(args).each do |sym, value|
        localenv.define(sym, value)
      end
      @code.map { |c| c.scm_eval(localenv) }.last
    end
    
    def to_scm
      "(lambda #{@params.to_scm} #{@code.map {|x| x.to_scm}.join(' ')})"
    end
    
    def to_proc
      return lambda { |*args| self.call(*args) }
    end
  end
end
