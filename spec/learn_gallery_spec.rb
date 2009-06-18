require File.dirname(__FILE__) + '/spec_helper'

describe "The ART GALLERY project" do
  it "Should have a gallery controller" do
    controller_exist?('gallery').should eql(true)
  end
  it "Should have a painting scaffold" do
    scaffold_exist?('painting').should eql(true)
  end
end

if controller_exist?('gallery')
  
  describe 'The GalleryController class', :type => :controller do
    controller_name :gallery
    it "Should have an index action" do
      controller.respond_to?(:index).should be_true
    end
    it "Index should say 'Hello my dear visitor!'" do
      get :index
      response.should include_text 'Hello my dear visitor!'
    end
    it "Should have an about action" do
      controller.respond_to?(:about).should be_true
    end
    it "About action should say 'E-learning is fun!'" do
      get :about
      response.should include_text 'E-learning is fun!'
    end
  end

end