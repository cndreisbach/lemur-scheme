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
      Parser.parse(string).map do |exp|
        exp.to_list.lispeval(@env, @forms)
      end.last
    end
    
    def repl
      loop do
        line = Readline::readline('> ')
        Readline::HISTORY.push(line)
        begin
          puts self.eval(line).to_scm
        rescue StandardError => e
          puts "ERROR: #{e}"
        end
      end
    end    
  end
end
