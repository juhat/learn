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

class LessonPhp < Course
end
