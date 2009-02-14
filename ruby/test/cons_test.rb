require 'test_helper'

class ConsTest < Test::Unit::TestCase
  include Lemur
  
  context "The Cons class" do
    should "be able to create a well-formed list from an array" do
      list = Cons.from_a([:hello, :world])
      assert list.list?
    end
  end
  
  context "A cons" do
    setup do
      @cons = Cons.new(1, nil)
    end
    
    should "be a pair" do
      assert @cons.pair?
    end
    
    should "be equal to an equivalent cons" do
      assert @cons.eql?(Cons.new(1, nil))
    end
    
    should "not be equal to non-equivalent cons" do
      assert !@cons.eql?(Cons.new(2, nil))
    end
  end
  
  context "A well-formed cons" do
    setup do
      @cons = Cons.new(:hello, Cons.new(:world, nil))
    end
    
    should "be a list" do
      assert @cons.list?
    end
    
    should "be a valid cdr" do
      newlist = Cons.new(:foo, @cons)
      assert_equal @cons, newlist.cdr
      assert newlist.list?
    end
    
    should "be able to become an array" do
      assert_equal [:hello, :world], @cons.to_array
    end
    
    should "represent itself as a sexp" do
      assert_equal "(hello world)", @cons.to_scm
    end
  end
  
  context "A dotted pair" do
    setup do
      @cons = Cons.new(:hello, :world)
    end
    
    should "not be a list" do
      assert !@cons.list?
    end
    
    should "not be able to become an array" do
      assert_not_equal [:hello, :world], @cons.to_array
    end
    
    should "be able to represent itself as a sexp" do
      assert_equal "(cons hello world)", @cons.to_scm
    end
  end
end
