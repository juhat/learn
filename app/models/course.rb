# == Schema Information
# Schema version: 20090415192933
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
  has_many :lessons
  has_and_belongs_to_many :users
  
  def path( user )
    File.join( user.path, id.to_s )
  end
  def ensure_path( user )
    logger.info("COURSE ENSURE_PATH #{path( user )} for USER #{user.email}")

    user.ensure_path
    
    FileUtils.mkdir_p( path( user ) ) unless File.exists?( path( user ) )
    begin
      FileUtils.chmod_R( 0711, path( user ) )
      FileUtils.chown( user.os_user, user.os_user, path( user ) )
    rescue ArgumentError => e
      logger.info("COURSE ENSURE_PATH #{path( user )} for USER #{user.email} PROBLEM #{e.to_s}")
    end
    
    logger.info("COURSE ENSURE_PATH END #{path( user )} for USER #{user.email}") 
  end
end
