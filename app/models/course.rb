class Course < ActiveRecord::Base
  has_many :lesson, :order => "position"
end
