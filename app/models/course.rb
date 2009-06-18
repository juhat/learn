# == Schema Information
# Schema version: 20090617162631
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
end
