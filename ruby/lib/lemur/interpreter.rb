require 'readline'

module Lemur
  class Interpreter
    SCHEME_BUILTINS = File.join(LEMUR_HOME, 'scheme', 'builtins.scm')
    
    def initialize(defaults = DEFAULTS, forms = FORMS)
      @env = Env.new(nil, defaults.clone)
      @forms = Env.new(nil, forms.clone)
      
      self.eval(File.read(SCHEME_BUILTINS))
    end
    
    def eval(string)
      string.parse_sexp.map do |exp|
        exp.consify.lispeval(@env, @forms)
      end.last
    end
    
    def repl
      loop do
        line = Readline::readline('> ')
        Readline::HISTORY.push(line)
        begin
          puts self.eval(line).to_sexp
        rescue StandardError => e
          puts "ERROR: #{e}"
        end
      end
    end
    
    def self.scheme_bool(predicate)
      predicate ? :t : :nil
    end
    
    DEFAULTS = {
      :nil => :nil,
      :t => :t,
      :+ => lambda { |*args| args.inject { |x, y| x + y } },
      :- => lambda { |*args| args.inject { |x, y| x - y } },
      :* => lambda { |*args| args.inject { |x, y| x * y } },
      :"/" => lambda { |*args| args.inject { |x, y| x / y } },
      :atom? => lambda { |x| scheme_bool(!x.kind_of?(Cons)) },
      :eq? => lambda { |x, y| scheme_bool(x.equal?(y)) },
      :list => lambda { |*args| Cons.from_a(args) },
      :print => lambda { |*args| puts *args.map { |a| a.to_sexp }; :nil },
    }

    FORMS = {
      :eval => lambda { |env, forms, *code| 
        code.map { |c| c.lispeval(env, forms) }.map { |c| c.lispeval(env, forms) }.last
      },
      :quote => lambda { |env, forms, exp| exp },
      :define => lambda { |env, forms, sym, value| 
        env.define(sym, value.lispeval(env, forms))
      },
      :set! => lambda { |env, forms, sym, value| 
        env.set!(sym, value.lispeval(env, forms))
      },
      :lambda => lambda { |env, forms, params, *code|
        Lambda.new(env, forms, params, *code)
      },
      :if => lambda { |env, forms, cond, xthen, xelse|
        if cond.lispeval(env, forms) != :nil
          xthen.lispeval(env, forms)
        else
          xelse.lispeval(env, forms)
        end
      },
      :defmacro => lambda { |env, forms, name, exp|
        func = exp.lispeval(env, forms)
        forms.define(name, lambda { |env2, forms2, *rest| 
          func.call(*rest).lispeval(env, forms)
        })
        name
      },
      :ruby => lambda { |env, forms, name| 
        Kernel.const_get(name)
      },
      %s[!] => lambda { |env, forms, object, message, *params|
        evaled_params = params.map { |p| p.lispeval(env, forms).arrayify }
        proc = evaled_params.last.kind_of?(Lambda) ? evaled_params.pop : nil
        object.lispeval(env, forms).send(message, *evaled_params, &proc).consify
      }
    }
  end
end
