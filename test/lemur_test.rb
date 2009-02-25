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
  end
end
