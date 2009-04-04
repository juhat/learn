class HomeController < ApplicationController
  layout 'simple'
  before_filter :login_required, :except=>['index']

  def course
    render :layout => 'simple950'  
  end
end
