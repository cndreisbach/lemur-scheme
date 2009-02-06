module Lemur
  class Interpreter
    def initialize(defaults = Lemur::DEFAULTS, forms = Lemur::FORMS)
      @env = Env.new(nil, defaults)
      @forms = Env.new(nil, forms)
    end
    
    def eval(string)
      string.parse_sexp.map do |exp|
        exp.consify.lispeval(@env, @forms)
      end.last
    end
    
    def repl
      print "> "
      STDIN.each_line do |line|
        begin
          puts self.eval(line).to_sexp
        rescue StandardError => e
          puts "ERROR: #{e}"
        end
        print "> "
      end
    end
  end
end
