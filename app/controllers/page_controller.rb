class PageController < ApplicationController
  before_filter :ajax_call
  
  private
  def ajax_call
    if request.xhr?
      render :layout =>false
    end
    return true
  end
end

