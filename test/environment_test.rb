require File.dirname(__FILE__) + '/test_helper'

class EnvironmentTest < Test::Unit::TestCase
  include Lemur
  
  context "an Environment" do
    setup do
      @env = Environment.new
    end    
  end
end
