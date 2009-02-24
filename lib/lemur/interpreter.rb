require 'readline'

module Lemur
  class Interpreter
    include Lemur
    
    def initialize(defaults = DEFAULTS, forms = FORMS)
      @env = Environment.new(nil, defaults.clone)
      @forms = Environment.new(nil, forms.clone)
      
      self.eval(File.read(SCHEME_BUILTINS))
    end
    
    def eval(string)
      Parser.parse(string).map { |exp|
        exp.to_cons.scm_eval(@env, @forms) }.last
    end
        
  end
end
