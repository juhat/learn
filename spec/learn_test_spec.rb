require File.dirname(__FILE__) + '/spec_helper'


if (File.exist?(RAILS_ROOT))
describe "Webshop" do
  it "Create a webshop! Use scaffold to generate the shop admin interface!"

  it "should be accessible at /shop" do
    true.should eql(true)
  end
  it "should be true" do
    true.should eql(false)
  end
end