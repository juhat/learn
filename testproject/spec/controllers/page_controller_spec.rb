require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PageController do

  it "should use PageController" do
    get 'index'
    1.should eql(2)
    response.should include_text('hello')
  end
end

describe PageController, "hello_template action" do
  it "should use a @text variable" do
    get 'hello_template'
    assigns.should have_key(:text)
  end
end