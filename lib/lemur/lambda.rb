module Lemur
  class Lambda
    def initialize(env, params, *code)
      @env = env
      @params = params.to_array
      @code = code
    end
    
    def call(*args)
      scope = Scope.new(@env)
      if @params.respond_to?(:size)
        raise "Expected #{@params.size} arguments" unless args.size == @params.size
        @params.zip(args).each do |sym, value|
          scope.define(sym, value)
        end
      else
        scope.define(@params, args.to_cons)
      end
      @code.map { |c| c.scm_eval(scope) }.last
    end
    
    def to_scm
      "(lambda #{@params.to_scm} #{@code.map {|x| x.to_scm}.join(' ')})"
    end
    
    def to_proc
      return lambda { |*args| self.call(*args) }
    end
  end
end
