$:.push(File.dirname(__FILE__))
LEMUR_HOME = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'rubygems'

%w(object_extensions cons environment lambda parser interpreter).each do |lib|
  require "lemur/#{lib}"
end

module Lemur
  
  SCHEME_BUILTINS = File.join(LEMUR_HOME, 'lib', 'builtins.scm')

  DEFAULTS = {
    :+ => lambda { |*args| args.inject { |x, y| x + y } },
    :- => lambda { |*args| args.inject { |x, y| x - y } },
    :* => lambda { |*args| args.inject { |x, y| x * y } },
    :"/" => lambda { |*args| args.inject { |x, y| x / y } },
    :eq? => lambda { |x, y| x.eql?(y) },
    :list => lambda { |*args| Cons.from_a(args) },
    :print => lambda { |*args| puts *args.map { |a| a.to_scm } }
  }

  FORMS = {
    :begin => lambda { |env, forms, *code| 
      code.map { |c| c.scm_eval(env, forms) }.last
    },
    :define => lambda { |env, forms, sym, *values|
      if sym.is_a?(Cons)
        env.define(sym.car, Lambda.new(env, forms, sym.cdr, *values))
      else
        env.define(sym, values.map { |v| v.scm_eval(env, forms) }.last)
      end
    },    
    :set! => lambda { |env, forms, sym, value| 
      env.set!(sym, value.scm_eval(env, forms))
    },
    :eval => lambda { |env, forms, *code| 
      code.map { |c| c.scm_eval(env, forms) }.map { |c| c.scm_eval(env, forms) }.last
    },
    :quote => lambda { |env, forms, exp| exp },
    :unquote => lambda { |env, forms, exp| exp.scm_eval(env, forms) },
    :quasiquote => lambda { |env, forms, exp|
      if exp.atom?
        exp
      else
        if exp.car == :unquote
          FORMS[:unquote][env, forms, exp]  
        else
          exp.to_array.map { |elem| FORMS[:quasiquote][env, forms, elem] }.to_cons
        end
      end
    },
    :lambda => lambda { |env, forms, params, *code|
      Lambda.new(env, forms, params, *code)
    },
    :and => lambda { |env, forms, *code|
      code.inject(true) { |result, c|
        (result != false) ? c.scm_eval(env, forms) : false
      }
    },
    :or => lambda { |env, forms, *code| 
      code.inject(false) { |result, c|
        (result != true) ? c.scm_eval(env, forms) : result
      }
    },
    :if => lambda { |env, forms, cond, *code|
      raise "Too many clause in if" if code.length > 2
      xthen, xelse = *code
      if cond.scm_eval(env, forms)
        xthen.scm_eval(env, forms)
      else
        xelse.nil? ? false : xelse.scm_eval(env, forms)
      end
    },
    :cond => lambda { |env, forms, *code|
      passed = false
      result = false
      
      code.each do |c|
        if passed == false && c.car.scm_eval(env, forms) != false
          passed = true
          result = c.cdr.car.scm_eval(env, forms)
        end
      end
      
      result
    },
    :defmacro => lambda { |env, forms, name, exp|
      func = exp.scm_eval(env, forms)
      forms.define(name, lambda { |env2, forms2, *rest| 
                     func.call(*rest).scm_eval(env, forms)
                   })
      name
    },
    :ruby => lambda { |env, forms, *names| 
      names.inject(Kernel) { |mod, name| mod.const_get(name) }
    },
    %s[!] => lambda { |env, forms, object, message, *params|
      evaled_params = params.map { |p|
        p.scm_eval(env, forms).to_array
      }
      proc = evaled_params.last.kind_of?(Lambda) ? evaled_params.pop : nil
      object.scm_eval(env, forms).send(message, *evaled_params, &proc).to_cons
    }
  }
    
end
