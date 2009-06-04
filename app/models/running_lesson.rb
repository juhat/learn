# == Schema Information
# Schema version: 20090804142735
#
# Table name: running_lessons
#
#  id                :integer(4)      not null, primary key
#  lesson_id         :integer(4)
#  user_id           :integer(4)
#  running_course_id :integer(4)
#  state             :string(255)     default("new")
#  created_at        :datetime
#  updated_at        :datetime
#

class RunningLesson < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user
  
  belongs_to :lesson
  validates_presence_of :lesson

  has_one :resource_url
  validates_presence_of :resource_url

  belongs_to :running_course
  validates_presence_of :running_course
  
  
  
  before_create :create_directories
  
  include AASM
  aasm_column :state
  
  private
  
  def create_directories
    
  end
end
