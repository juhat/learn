# == Schema Information
# Schema version: 20090415162021
#
# Table name: courses
#
#  id          :integer(4)      not null, primary key
#  type        :string(255)
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class LessonRails < Course
end
