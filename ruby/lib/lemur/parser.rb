require 'rubygems'
require 'rparsec'

module Lemur
  module Parser
    extend RParsec::Parsers
        
    Integer = integer.map { |x| x.to_i }
    Float = number.map { |x| x.to_f }
    Number = longest(Integer, Float)
    Special = Regexp.escape '+-*/=<>?!@#$%^&:~'
    Symbol = regexp(/[\w#{Special}]*[A-Za-z#{Special}][\w#{Special}]*/).map { |x| x.to_sym }
    Escape = (string('\\') >> any)
    Quote = string('"')
    NotQuote = not_string('"')
    String = (Quote >> (Escape|NotQuote).many << Quote).map { |charseq|
      charseq.map { |charnum| charnum.chr }.to_s
    }
    Quoted = char("'") >> lazy { Value }.map { |value| [:quote, value] }
    List = char('(') >> lazy { Values } << char(')')
    Value = alt(Quoted, List, String, Number, Symbol)
    Values = Value.lexeme(whitespaces | comment_line(';'))
    
    Parser = Values << eof
    
    def self.parse(text)
      Parser.parse(text.strip)
    end
  end
end
