class HomeController < ApplicationController
  layout 'simple'
  
  def test
    render :layout=>'course'
  end
end
