# == Schema Information
# Schema version: 20090804142735
#
# Table name: running_courses
#
#  id         :integer(4)      not null, primary key
#  course_id  :integer(4)
#  user_id    :integer(4)
#  state      :string(255)     default("new")
#  created_at :datetime
#  updated_at :datetime
#

class RunningCourse < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_many :running_lessons
  
  validates_presence_of :user
  validates_presence_of :course
end
