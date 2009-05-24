class RunningCourse < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_many :running_lessons
  
  validates_presence_of :user
  validates_presence_of :course
end