class HomeController < ApplicationController
  def index
    @courses = Course.find(:all)
  end
  
  def create_lesson
    `rm -rf course/users/1/rails/*`
    `cp -R course/rails/1/* course/users/1/rails/`
    redirect_to :action => "start_lesson"
  end
  
  def start_lesson
    `rm -rf public/A/*`
    `cp -R course/users/1/rails/* public/A/`
    # `chown -R #{Course.getOsUserAndGroup} /public/A/. `
    `touch public/A/tmp/restart.txt`
    redirect_to :action=>'do_lesson'
  end
  
  def do_lesson
    render :layout=>'learn'
  end
  
  def stop_lesson
    `rm -rf course/users/1/rails/*`
    `cp -R public/A/* course/users/1/rails/`
    `rm -rf public/A/*`
    `touch public/A/tmp/restart.txt`
    redirect_to :action => "index"
  end
end
