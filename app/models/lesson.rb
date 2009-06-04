# == Schema Information
# Schema version: 20090804142735
#
# Table name: lessons
#
#  id          :integer(4)      not null, primary key
#  type        :string(255)
#  name        :string(255)
#  description :text
#  course_id   :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

class Lesson < ActiveRecord::Base
  belongs_to :course
  validates_presence_of :course
  
  has_many :running_lessons
  has_many :users, :through => :running_lessons
  
  
  def start( user )
    logger.info("LESSON #{self.course.name}:#{self.name} starting by USER #{user.email}")
    
    ensure_path( user )
    
    logger.info("LESSON #{self.name} started by USER #{user.email}")
  end
  
  def stop
  end
  
  def relink
  end
  
  def restart
  end
  
  def restart_server  
  end

  def path( user )
    File.join( course.path( user ), id.to_s )
  end
  
  def ensure_path( user )
    logger.info("LESSON ENSURE_PATH #{path( user )} for USER #{user.email}")
    
    course.ensure_path( user )
    
    FileUtils.mkdir_p( path( user ) ) unless File.exists?( path( user ) )
    `sudo chmod 711 #{path( user )}`
    `sudo chown #{user.os_user}:#{user.os_group} #{path( user )}`
  end


    
  def start_lesson
    `tar czvf #{path}/saved/#{Time.now.strftime("%y%m%d%H%M%S")}.tar.gz #{path}/active`
    `rm -rf #{active_path}`
    `cp -R #{RAILS_ROOT}/courses/testproject_skel #{active_path}`
    `cp #{RAILS_ROOT}/courses/learn_gallery_spec.rb #{active_path}/spec/learn_gallery_spec.rb`
    `cp #{RAILS_ROOT}/courses/learn_story.html #{active_path}/spec/learn_story.html`

    `cp #{RAILS_ROOT}/spec/spec.opts #{active_path}/spec/spec.opts`
    `cp #{RAILS_ROOT}/spec/spec_helper.rb #{active_path}/spec/spec_helper.rb`
    `cp #{RAILS_ROOT}/app/controllers/learn_course_controller.rb #{active_path}/app/controllers/learn_course_controller.rb`
    relink_course
    # handling user rights
    restart_course_server
    # self.resource_url ||= ResourceUrl.first :conditions => ['user_id = NULL']
  end
  def relink_lesson
    # it works for development only / it paired with the user.atti.la virtualhost
    `rm -f #{RAILS_ROOT}/testproject`
    `ln -s #{active_path} #{RAILS_ROOT}/testproject`
  end
  def restart_lesson
    start_course
  end
  def restart_lesson_server
    `touch #{active_path}/tmp/restart.txt`
  end


  # false in case of problem
  def lesson_host
    return self.resource_url.key
    
    unless RAILS_ENV == 'development'
      # unless resource_url
      #   r = ResourceUrl.find(:first, :conditions => [ "user_id = ?", nil], :order => "updated_at DESC")
      #   if r
      #     resource_url = r
      #     return resource_url
      #   else
      #     return false
      #   end
      # end
    else
      return 'user.atti.la'
    end
  end
  
  # true if success
  def release_lesson_host
    if RAILS_ENV == 'production'
      # release the resource
    end
  end
  
end
