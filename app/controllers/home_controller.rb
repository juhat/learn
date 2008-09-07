class HomeController < ApplicationController
  before_filter :login_required, :only => [ :user ]
    
  def index
    @courses = Course.find(:all)
  end
  
  def create_lesson
    `mkdir -p courses_saved/user1/rails1/`
    `rm -rf courses_saved/user1/rails1/*`
    `cp -R courses/rails1/* courses_saved/user1/rails1/`
    redirect_to :action => "start_lesson"
  end
  # not changed below
  def start_lesson
    `mkdir -p /home/user1/rails/`
    `rm -rf /home/user1/rails/*`
    `cp -R courses_saved/user1/rails/* /home/user1/rails`
    `find /home/user1/rails/. -type d -exec chmod 770 {} \\;`
    `find /home/user1/rails/. -type f -exec chmod 660 {} \\;`
    `chown -R /home/user1/rails/* user1:user1`
    
    `rm /home/test/rails_1`
    `ln -s /home/user1/test /home/test/rails_1`
    
    `touch /home/user1/test/tmp/restart.txt`
    redirect_to :action=>'do_lesson'
  end
  
  def do_lesson
    render :layout=>'learn'
  end
  
  def stop_lesson
    `rm -rf courses/users/1/rails/*`
    `cp -R /home/user1/test/* courses/users/1/rails/`
    `rm -rf /home/user1/test/*`
    
    `rm /home/test/rails_1`
    `ln -s /home/test/public_html /home/test/rails_1`
    
    `touch /home/user1/test/tmp/restart.txt`
    redirect_to :action => "index"
  end
end
