require 'test_helper'
require 'lemur/parser'

class ParserTest < Test::Unit::TestCase
  include Lemur::Parser
  ParserException = RParsec::ParserException
  
  should "parse integers" do
    assert_equal 23, Integer.parse('23')
    assert_raises(ParserException) do
      Integer.parse('twenty-three')
    end
  end
  
  should "parse floats" do
    assert_equal 3.14, Float.parse("3.14")
    assert_raises(ParserException) do
      Float.parse('pi')
    end
  end
  
  should "parse numbers" do
    assert 37.eql?(Number.parse("37"))
    assert 2.5.eql?(Number.parse("2.5"))
  end
  
  should "parse symbols" do
    assert_equal :hello, Symbol.parse('hello')
    assert_equal :+, Symbol.parse('+')
    assert_equal %s[<+>], Symbol.parse('<+>')
    assert_equal :ei8ht, Symbol.parse('ei8ht')
    assert_equal %s[2wice], Symbol.parse('2wice')
    assert_raises(ParserException) { Symbol.parse '234' }
  end
  
  should "parse values" do
    assert_equal :hello, Value.parse('hello')
    assert_equal 1.41, Value.parse('1.41')
    assert_equal 1976, Value.parse('1976')
  end
  
  should "parse multiple values" do
    assert_equal [:foo, 1, :bar, 2], Values.parse('foo 1 bar 2')
  end
  
  should "parse an empty list" do
    assert_equal [], List.parse('()')
  end
  
  should "parse lists" do
    assert_equal [:+, :foo, 2], List.parse('(+ foo 2)')
  end
  
  should "parse nested lists" do
    assert_equal([:foo, [:bar, :baz, [1, 2], []], 3, [4, 5]],
      List.parse('(foo (bar baz (1 2) ()) 3 (4 5))'))
  end
  
  should "parse lists that have spaces between endings" do
    assert_equal [:foo, :bar], List.parse('(foo bar )')
  end
  
  should "parse strings" do
    assert_equal "hello world", String.parse('"hello world"')
    assert_equal '"', String.parse('"\""')
  end

  should "parsed quoted stuff" do
    assert_equal [:quote, :foo], Quoted.parse("'foo")
    assert_equal [:quote, [:foo, 1, 2]], Quoted.parse("'(foo 1 2)")
    assert_equal [:quote, [:foo, [:quote, 1], 2]], Quoted.parse("'(foo '1 2)")
    assert_equal [:quote, [:quote, [:foo, 1, 2]]], Quoted.parse("''(foo 1 2)")
  end
  
  should "parse s-expressions" do
    assert_equal [[:+, [:max, 2, 3], 7]], Parser.parse('(+ (max 2 3) 7)')
  end
  
  should "parse s-expressions with comments" do
    assert_equal [[:+, 1, 2]], Parser.parse(%Q{
      (+ ; plus-sign
       1 ; the number one
       2 ; the number two
      ) ; close s-expression
    }.strip)
  end  
end

