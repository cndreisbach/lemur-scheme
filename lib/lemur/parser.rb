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

    Escape = (string('\\') >> any)
    Quote = string('"')
    NotQuote = not_string('"')
    String = (Quote >> (Escape|NotQuote).many << Quote).map { |charseq|
      charseq.map { |charnum| charnum.chr }.to_s
    }

    Quoted = modifier("'", :quote)
    Quasiquoted = modifier("`", :quasiquote)
    Unquoted = modifier(",", :unquote)

    EmptyList = (char('(') >> whitespace.many << char(')')).map { |x| nil }
    List = char('(') >> lazy { Values } << char(')')
    
    Value = alt(Quoted, Quasiquoted, Unquoted, EmptyList, List, Number, Boolean, Symbol, String)
    Values = Value.lexeme(whitespaces | comment_line(';'))
    Parser = Values << eof
  end
end
