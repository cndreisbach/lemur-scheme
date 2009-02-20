require 'rubygems'
require 'rparsec'

module Lemur
  module Parser
    extend RParsec::Parsers
    
    def self.parse(text)
      Parser.parse(text.strip)
    end
    
    def self.modifier(char, symbol)
      char(char) >> lazy { Value }.map { |value| [symbol, value] }
    end
                
    Fraction = regexp(/\d+\/\d+/).map { |x|
      Rational(*x.split("/").map { |x| x.to_i }) 
    }
    Integer = integer.map { |x| x.to_i }
    Float = number.map { |x| x.to_f }
    Number = longest(Fraction, Integer, Float)
    Special = Regexp.escape '+-*/=<>?!@#$%^&:~'
    Boolean = regexp(/\#[tf]/).map { |x| x == "#t" }
    Symbol = regexp(/[\w#{Special}]*[A-Za-z#{Special}][\w#{Special}]*/).map { |x| x.to_sym }
    Escape = (string('\\') >> any)
    Quote = string('"')
    NotQuote = not_string('"')
    String = (Quote >> (Escape|NotQuote).many << Quote).map { |charseq|
      charseq.map { |charnum| charnum.chr }.to_s
    }

    Quoted = modifier("'", :quote)
    Quasiquoted = modifier("`", :quasiquote)
    Unquoted = modifier(",", :unquote)
    
    List = char('(') >> lazy { Values } << char(')')
    Value = alt(Quoted, Quasiquoted, Unquoted, List, Number, Boolean, Symbol, String)
    Values = Value.lexeme(whitespaces | comment_line(';'))
    
    Parser = Values << eof
  end
end
