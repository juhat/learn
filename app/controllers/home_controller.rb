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
    `rm -rf /home/user1/test/*`
    `cp -R course/users/1/rails/* /home/user1/test`
    `chown -R /home/user1/test/*`
    
    `rm /home/test/rails_1`
    `ln -s /home/user1/test /home/test/rails_1`
    
    `touch /home/user1/test/tmp/restart.txt`
    redirect_to :action=>'do_lesson'
  end
  
  def do_lesson
    render :layout=>'learn'
  end
  
  def stop_lesson
    `rm -rf course/users/1/rails/*`
    `cp -R /home/user1/test/* course/users/1/rails/`
    `rm -rf /home/user1/test/*`
    
    `rm /home/test/rails_1`
    `ln -s /home/test/public_html /home/test/rails_1`
    
    `touch /home/user1/test/tmp/restart.txt`
    redirect_to :action => "index"
  end
end
