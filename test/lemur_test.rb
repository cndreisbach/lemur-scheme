require File.dirname(__FILE__) + '/test_helper'

class LemurTest < Test::Unit::TestCase
  include Lemur
  
  context "A Lemur interpreter" do
    setup do
      @int = Interpreter.new
    end
    
    should "be able to eval" do
      assert_equal 6, @int.eval('(eval (quote (+ 1 2 3)))')
      assert_equal 10, @int.eval('(eval (quote (+ 1 2 3 4)))')
    end
    
    should "have lexical macros" do
      @int.eval "(define a (lambda () (defmacro myquote (lambda (thing) (list (quote quote) thing))) (myquote b)))"
      assert_raises(RuntimeError) { @int.eval "(myquote b)" }
      @int.eval "(a)"
      assert_raises(RuntimeError) { @int.eval "(myquote b)" }
    end
  end
end
