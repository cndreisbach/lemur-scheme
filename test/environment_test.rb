require File.dirname(__FILE__) + '/test_helper'

class EnvironmentTest < Test::Unit::TestCase
  include Lemur
  
  context "an Environment" do
    setup do
      @env = Environment.new
    end
    
    should "be able to define symbols" do
      @env.define(:a, 1)
      assert @env.defined?(:a)
    end
    
    should "be able to lookup symbols" do
      @env.define(:a, 1)
      assert_equal 1, @env.lookup(:a)
    end
    
    should "be able to set symbols already defined" do
      @env.define(:a, 1)
      assert @env.set!(:a, 2)
      assert_equal 2, @env.lookup(:a)
    end
        
    context "with a parent" do
      setup do
        @child = Environment.new(@env)
      end
      
      should "be able to lookup a symbol in its parent" do
        @env.define(:a, 1)
        
        assert @child.defined?(:a)
        assert_equal 1, @child.lookup(:a)
      end        
    end
  end
end
