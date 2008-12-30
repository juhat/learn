class HomeController < ApplicationController
  layout 'simple'
  before_filter :login_required, :except=>['index']
  
end
