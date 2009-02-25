gradient: top-bottom blue brown

# Things I Learned While Implementing Scheme in Ruby

Clinton R. Nixon

# What's Lemur Scheme?

* A Scheme
* Implemented by me
* In Ruby
* With full Ruby interop

<pre class="code">
(define (cons car cdr) (! (ruby Lemur Cons) new car cdr))
</pre>

The goal is to create a R5RS-compliant Scheme.

# How to make your own Firefox search engine

<pre class="brush: xml">
<SearchPlugin xmlns="http://www.mozilla.org/2006/browser/search/" xmlns:os="http://a9.com/-/spec/opensearch/1.1/">
<os:ShortName>GitHub</os:ShortName>
<os:Description>GitHub</os:Description>
<os:InputEncoding>UTF-8</os:InputEncoding>
<os:Image width="16" height="16">data:image/x-icon;base64,AAABAAEAEBAAAAEAIABoB ... </os:Image>
<os:Url type="text/html" method="GET" template="http://github.com/search?q={searchTerms}">
</os:Url>
</SearchPlugin>
</pre>

Drop this in your Firefox profile folder (`~/Library/Application Support/Firefox/Profiles/*.profile/` on OS X, `~/.mozilla/firefox/*.profile/` on Ubuntu) and when you click on the search box, it'll ask you if you want to install it.

# pp

<pre class="brush: ruby">
require 'pp'
foo = Cons.new(32, Cons.new("bar", Cons.new([7, 3, 3, 4], nil)))
pp foo
</pre>

<pre class="code">
#&lt;Lemur::Cons:0xb79e31dc
  @car=32,
  @cdr=
   #&lt;Lemur::Cons:0xb79e3204
     @car="bar",
     @cdr=#&lt;Lemur::Cons:0xb79e3218 @car=[7, 3, 3, 4], @cdr=nil&gt;&gt;&gt;
</pre>

# RParsec is great

<pre class="brush: ruby">
module Lemur
  module Parser
    extend RParsec::Parsers
    
    Integer = integer.map { |x| x.to_i }
    RealNumber = number.map { |x| x.to_f }
    RationalNumber = sequence(Integer, char('/'), Integer) { |numer, slash, denom|
      Rational(numer, denom)
    }    
    Number = longest(RationalNumber, Integer, RealNumber)
    Boolean = regexp(/\#[tf]/).map { |x| x != "#f" }
    
    Special = Regexp.escape '+-*/=<>?!@#$%^&:~'
    Symbol = regexp(/[\w#{Special}]*[A-Za-z#{Special}][\w#{Special}]*/).map { |x|
      x.to_sym
    }

    List = char('(') >> lazy { Values } << char(')')
    
    Value = alt(List, Number, Boolean, Symbol)
    Values = Value.lexeme(whitespaces | comment_line(';'))
    Parser = Values << eof
  end
end
</pre>

# You can extend `nil`, `true`, and `false`

<pre class="brush: ruby">
module Lemur
  module NilExtensions
    def to_scm
      '()'
    end  
  end

  module TrueExtensions
    def to_scm
      '#t'
    end
  end

  module FalseExtensions
    def to_scm
      '#f'
    end
  end
end

NilClass.send(:include, Lemur::NilExtensions)
TrueClass.send(:include, Lemur::TrueExtensions)
FalseClass.send(:include, Lemur::FalseExtensions)
</pre>

# Simple things about scoping I never realized

<pre class="brush: ruby">
x = 1
foo = lambda { |y| x = y }
foo[7]
# =&gt; 7
</pre>

I had to implement this for Scheme:

<pre class="brush: ruby">
class Lemur::Scope
  def initialize(parent = nil)
    @parent = parent
    @defs = {}
  end

  def define(symbol, value)
    if !@defs.has_key?(symbol) and !@parent.nil? and @parent.defined?(symbol)
      @parent.define(symbol, value)
    else
      @defs[symbol] = value
    end
  end
end
</pre>

# Implementing lambda made me think about what goes on under the hood

<pre class="brush: ruby">
class Lemur::Lambda
  def initialize(scope, params, *code)
    @scope = scope
    @params = params.to_array
    @code = code
  end
end
</pre>

A reference to the calling scope stays around forever.

# This means you can change variables in the scope later

<pre class="brush: ruby">
bar = 17
foo = lambda { bar }
foo.call
# => 17

bar = :horse_dogg_maniac
foo.call
# => :horse_dogg_maniac
</pre>

I had assumed it captured the state of the environment at the time.

# Argument evaluation with lambdas

<pre class="brush: ruby">
class Lemur::Lambda
  def call(*args)
    raise "Expected #{@params.size} arguments" unless args.size == @params.size
    new_scope = Scope.new(@scope)
    @params.zip(args).each do |sym, value|
      new_scope.define(sym, value)
    end
    @code.map { |c| c.scm_eval(new_scope) }.last
  end
end

module Lemur::Cons
  def scm_eval(env)
    car.scm_eval(env).call(*cdr.to_array.map { |x| x.scm_eval(env) })
  end
end
</pre>

Each of the arguments is evaluated before evaluating the lambda.

# But what about keywords?

<pre class="brush: ruby">
:if => lambda { |env, cond, *code|
  raise "Too many clause in if" if code.length > 2
  xthen, xelse = *code
  if cond.scm_eval(env)
    xthen.scm_eval(env)
  else
    xelse.nil? ? false : xelse.scm_eval(env)
  end
}
</pre>

I can't evaluate the code, or the else clause would execute.

# By the way, Ruby 1.8 lambdas can suck it

<pre class="brush: ruby">
# ruby 1.8.7
:if => lambda { |env, cond, *code|
  raise "Too many clause in if" if code.length > 2
  xthen, xelse = *code
  ...
}

# ruby 1.9.1
:if = ->(env, cond, xthen, xelse = nil) { ... }
</pre>

# `readline` is super simple in the base case

<pre class="brush: ruby">
class Lemur::Repl
  def run
    loop do
      line = Readline::readline('> ')
      Readline::HISTORY.push(line)
      puts @interpreter.eval(line).to_scm
    end
  end     
end
</pre>

# Implementing a language (in Ruby) is easy

<pre class="code">
SLOC	Directory	SLOC-by-Language (Sorted)
1212    test            lisp=955,ruby=257
373     lib             ruby=355,lisp=18

Totals grouped by language (dominant language first):
lisp:           973 (61.39%)
ruby:           612 (38.61%)
</pre>

# yo dawg i heard you like ruby so i put some ruby in your scheme in your ruby

<pre class="brush: ruby">
require File.dirname(__FILE__) + '/lib/lemur'
include Lemur
lemur = Interpreter.new
lemur.eval %Q{(! (! (ruby File) open "#{__FILE__}") each (lambda (line) (print line)))}

"require File.dirname(__FILE__) + '/lib/lemur'\n"
"include Lemur\n"
"lemur = Interpreter.new\n"
"lemur.eval %Q{(! (! (ruby File) open \"\#{__FILE__}\") each (lambda (line) (print line)))}\n"
</pre>

# Process my interpreter uses

1. parse code
2. loop through array of code statements
3. execute statement recursively
4. WHAT
