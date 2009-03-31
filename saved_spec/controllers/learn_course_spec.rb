require File.dirname(__FILE__) + '/../spec_helper'

describe LearnCourseController do
  it "should get autotest" do
    get :autotest
    puts response.body
    # response.should
  end
end