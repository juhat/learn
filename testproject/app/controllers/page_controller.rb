class PageController < ApplicationController
  def index
    render :text=>'hello from world'
  end
  def hello_template
    @text = 'hello from template'
  end
end
