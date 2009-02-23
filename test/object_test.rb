require File.dirname(__FILE__) + '/test_helper'

class LemurTest < Test::Unit::TestCase
  context "Objects" do
    should "be atoms" do
      assert Object.new.atom?
    end

    should "not be pairs" do
      assert !Object.new.pair?
    end

    should "return themselves by default when evaluated" do
      object = Object.new
      assert object.equal?(object.scm_eval(nil, nil))
    end
  end

  context "Nil" do
    should "be a list" do
      assert nil.list?
    end

    should "be able to become an empty array" do
      assert_equal [], nil.to_array
    end
    
    should "have an external representation as an empty list" do
      assert_equal '()', nil.to_scm
    end
  end

  context "Booleans" do
    should "have an external representation" do
      assert_equal '#t', true.to_scm
      assert_equal '#f', false.to_scm
    end
  end

  context "Strings" do
    should "have an external representation as escaped strings" do
      assert_equal '"hello world"', "hello world".to_scm
      assert_equal %Q[this \"has\" quotes inside it], "this \"has\" quotes inside it"
    end
  end

  context "Arrays" do
    should "have an external representation as lists" do
      assert_equal "(1 2 3)", [1, 2, 3].to_scm
      assert_equal '(1 (a b) "what")', [1, [:a, :b], "what"].to_scm
    end
  end
end
