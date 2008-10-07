class HomeController < ApplicationController
  before_filter :login_required, :exept => [ :index ]
    
  def index
    @courses = Course.find(:all)
  end
  
  def order
    params[:sortable].each_with_index do |id, pos|
         Lesson.find(id).update_attribute(:position, pos+1)
       end
    render :nothing => true
  end
  
  def create_lesson
    logger.info `mkdir -p courses_saved/user#{current_user.id}/rails1/`
    logger.info `rm -rf courses_saved/user#{current_user.id}/rails1/*`
    logger.info `cp -R courses/rails1/* courses_saved/user#{current_user.id}/rails1/`
    # `find /home/user1/rails/. -type d -exec chmod 770 {} \\;`
    # `find /home/user1/rails/. -type f -exec chmod 660 {} \\;`
    redirect_to :action => "start_lesson"
  end
  # not changed below
  def start_lesson
    if isServer?
      logger.info `chown -R courses_saved/user#{current_user.id}/rails1/* user1:user1`
      logger.info `rm /home/test/rails_1`
      logger.info `ln -s courses_saved/user#{current_user.id}/rails1 /home/test/rails_1`
      logger.info `touch courses_saved/user#{current_user.id}/rails1/tmp/restart.txt`
    end
    redirect_to :action=>'do_lesson'
  end
  
  def do_lesson
    render :layout=>'learn'
  end
  
  def stop_lesson
    if isServer?
      `ln -s /home/test/public_html /home/test/rails_1`    
      `touch /home/user1/test/tmp/restart.txt`
    end
    redirect_to :action => "index"
  end
  
  protected
  def isServer?
    unless (request.headers['SERVER_NAME']=='dev.atti.la') 
      return true 
    else
      return false
    end
  end
end
