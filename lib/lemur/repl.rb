module Lemur
  class Repl
    def initialize(interpreter)
      @interpreter = interpreter
    end
    
    def run
      loop do
        line = Readline::readline('> ')
        Readline::HISTORY.push(line)
        begin
          puts @interpreter.eval(line).to_scm
        rescue StandardError => e
          puts "ERROR: #{e}"
        end
      end
    end     
  end
end