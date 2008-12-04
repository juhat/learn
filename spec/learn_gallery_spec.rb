require File.dirname(__FILE__) + '/spec_helper'

  describe "The art gallery project" do
    it "should have a gallery controller file" do
      controller_exist?('gallery').should eql(true)
    end
    it "should have a painting scaffold - each painting needs title, author and image_path attributes" do
      scaffold_exist?('painting').should eql(true)
    end
  end
  
  describe 'The GalleryController class', :type => :controller do
    controller_name :gallery
    it "should have an index action" do
      controller.respond_to?(:index).should be_true
    end
    it "should have an index action, and say 'Hello my dear visitor!'" do
      get :index
      response.should include_text 'Hello my dear visitor!'
    end
    it "should have an about action too" do
      controller.respond_to?(:about).should be_true
    end
    it "should render the about_me.html.erb template for about action" do
      get :about
      response.should render_template("gallery/about_me")
    end
    it "should have an about action telling us 'It is me!'" do
      get :about
      response.should include_text 'It is me!'
    end
  end

  # describe " .. " do
  #   it "------------------------------------------------------------------------------------------------------------------------------------------------------"
  # end