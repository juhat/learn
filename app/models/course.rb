# == Schema Information
# Schema version: 20090804142735
#
# Table name: courses
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Course < ActiveRecord::Base
  has_many :running_courses
  has_many :users, :through => :running_courses
  
  
  
  
  
  
  def path( user )
    File.join( user.path, id.to_s )
  end
  def ensure_path( user )
    logger.info("COURSE ENSURE_PATH #{path( user )} for USER #{user.email}")

    user.ensure_path
    
    FileUtils.mkdir_p( path( user ) ) unless File.exists?( path( user ) )
    `sudo chmod 711 #{path( user )}`
    `sudo chown #{user.os_user}:#{user.os_group} #{path( user )}`
  end
end
