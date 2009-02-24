require File.dirname(__FILE__) + '/test_helper'

class ScopeTest < Test::Unit::TestCase
  include Lemur
  
  context "a Scope" do
    setup do
      @scope = Scope.new
    end
    
    should "be able to define symbols" do
      @scope.define(:a, 1)
      assert @scope.defined?(:a)
    end
    
    should "be able to lookup symbols" do
      @scope.define(:a, 1)
      assert_equal 1, @scope.lookup(:a)
    end
    
    should "be able to set symbols already defined" do
      @scope.define(:a, 1)
      assert @scope.set!(:a, 2)
      assert_equal 2, @scope.lookup(:a)
    end
    
    context "with a parent" do
      setup do
        @child = Scope.new(@scope)
      end
      
      should "be able to lookup a symbol in its parent" do
        @scope.define(:a, 1)
        
        assert @child.defined?(:a)
        assert_equal 1, @child.lookup(:a)
      end        
    end
  end
end
