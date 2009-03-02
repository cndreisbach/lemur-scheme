module Lemur
  class Repl
    def initialize(interpreter)
      @interpreter = interpreter
    end
    
    def run
      puts "; Welcome to the Lemur Scheme REPL!"
      puts "; Enter your expressions below, and they will be evaluated."
      puts "; Expression results will appear as comments.\n\n"
      exp = ''
      loop do
        line = Readline::readline('')
        Readline::HISTORY.push(line)
        exp += line
        begin
          puts "; #{@interpreter.eval(exp).to_scm}\n\n"
        rescue RParsec::ParserException => e
          if e.to_s =~ /^'\)' expected/
            line += " "
            redo
          else
            puts "; SYNTAX ERROR: #{e}\n\n"
          end
        rescue StandardError => e
          puts "; ERROR: #{e}\n\n"
        end
        exp = ''
      end
    end     
  end
end