$:.push(File.dirname(__FILE__))
LEMUR_HOME = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'rubygems'

[ :object_extensions,
  :cons,
  :scope,
  :environment,
  :lambda,
  :parser,
  :interpreter,
  :repl ].each do |lib|
  require "lemur/#{lib}"
end

module Lemur
  
  SCHEME_BUILTINS = File.join(LEMUR_HOME, 'lib', 'builtins.scm')

  FORMS = {
    :begin => lambda { |env, *code| 
      code.map { |c| c.scm_eval(env) }.last
    },
    :define => lambda { |env, sym, *values|
      if sym.is_a?(Cons)
        env.define(sym.car, Lambda.new(env, sym.cdr, *values))
      else
        env.define(sym, values.map { |v| v.scm_eval(env) }.last)
      end
    },    
    :set! => lambda { |env, sym, value| 
      env.set!(sym, value.scm_eval(env))
    },
    :eval => lambda { |env, *code| 
      code.map { |c| c.scm_eval(env) }.map { |c| c.scm_eval(env) }.last
    },
    :quote => lambda { |env, exp| exp },
    :unquote => lambda { |env, exp| exp.scm_eval(env) },
    :quasiquote => lambda { |env, exp|
      if exp.atom?
        exp
      else
        if exp.car == :unquote
          FORMS[:unquote][env, exp]  
        else
          exp.to_array.map { |elem| FORMS[:quasiquote][env, elem] }.to_cons
        end
      end
    },
    :lambda => lambda { |env, params, *code|
      Lambda.new(env, params, *code)
    },
    :and => lambda { |env, *code|
      code.inject(true) { |result, c|
        (result != false) ? c.scm_eval(env) : false
      }
    },
    :or => lambda { |env, *code| 
      code.inject(false) { |result, c|
        (result != true) ? c.scm_eval(env) : result
      }
    },
    :if => lambda { |env, cond, *code|
      raise "Too many clause in if" if code.length > 2
      xthen, xelse = *code
      if cond.scm_eval(env)
        xthen.scm_eval(env)
      else
        xelse.nil? ? false : xelse.scm_eval(env)
      end
    },
    :cond => lambda { |env, *code|
      passed = false
      result = false
      
      code.each do |c|
        if passed == false && c.car.scm_eval(env) != false
          passed = true
          result = c.cdr.car.scm_eval(env)
        end
      end
      
      result
    },
    :defmacro => lambda { |env, name, exp|
      func = exp.scm_eval(env)
      FORMS[name] = lambda { |env2, *rest| 
                     func.call(*rest).scm_eval(env)
                   }
      name
    },
    :ruby => lambda { |env, *names| 
      names.inject(Kernel) { |mod, name| mod.const_get(name) }
    },
    %s[!] => lambda { |env, object, message, *params|
      evaled_params = params.map { |p|
        p.scm_eval(env).to_array
      }
      proc = evaled_params.last.kind_of?(Lambda) ? evaled_params.pop : nil
      object.scm_eval(env).send(message, *evaled_params, &proc).to_cons
    }
  }
    
end
