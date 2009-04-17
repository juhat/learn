class RunningLesson < ActiveRecord::Base
  belongs_to :user
  belongs_to :lesson
  has_one :resource_url
  
  validates_presence_of :user
  validates_presence_of :lesson
  validates_presence_of :resource_url
  
  before_create :create_directories
  
  
  private
  
  def create_directories
    
  end
end
