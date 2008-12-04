require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "controller", :type => :model do
  before do
    true
  end
  
  it "should description"
  
  it "should be true" do
    true.should eql(true)
  end 
  it "should be false" do
    true.should eql(false)
  end
end