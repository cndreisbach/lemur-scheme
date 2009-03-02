require 'readline'

module Lemur
  class Interpreter
    include Lemur
    
    def initialize
      @env = Environment.new      
      self.eval(File.read(SCHEME_BUILTINS))
      self.eval(File.read(File.join(LEMUR_HOME, 'lib', 'little-schemer.scm')))
    end
    
    def eval(string)
      Parser.parse(string).map { |exp|
        exp.to_cons.scm_eval(@env) }.last
    end
        
  end
end
