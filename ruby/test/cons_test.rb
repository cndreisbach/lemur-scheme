require 'test_helper'

class ConsTest < Test::Unit::TestCase
  include Lemur
  
  context "The Cons class" do
    should "be able to create a well-formed cons from an array" do
      cons = Cons.from_a([:hello, :world])
      assert cons.conslist?
    end
  end
  
  context "A well-formed cons" do
    setup do
      @cons = Cons.new(:hello, Cons.new(:world, :nil))
    end
    
    should "be a conslist" do
      assert @cons.conslist?
    end
    
    should "be a valid cdr" do
      newcons = Cons.new(:foo, @cons)
      assert_equal @cons, newcons.cdr
      assert newcons.conslist?
    end
    
    should "be able to become an array" do
      assert_equal [:hello, :world], @cons.arrayify
    end
    
    should "represent itself as a sexp" do
      assert_equal "(hello world)", @cons.to_sexp
    end
  end
  
  context "A dotted pair" do
    setup do
      @cons = Cons.new(:hello, :world)
    end
    
    should "not be a conslist" do
      assert !@cons.conslist?
    end
    
    should "not be able to become an array" do
      assert_not_equal [:hello, :world], @cons.arrayify
    end
    
    should "be able to represent itself as a sexp" do
      assert_equal "(cons hello world)", @cons.to_sexp
    end
  end
end