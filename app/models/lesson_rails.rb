# == Schema Information
# Schema version: 20090604140343
#
# Table name: courses
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class LessonRails < Course
end
