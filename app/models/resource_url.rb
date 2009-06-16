# == Schema Information
# Schema version: 20090604140343
#
# Table name: resource_urls
#
#  id                :integer(4)      not null, primary key
#  url               :string(255)
#  type              :string(255)
#  running_lesson_id :integer(4)
#  created_at        :datetime
#  updated_at        :datetime
#

class ResourceUrl < ActiveRecord::Base
  belongs_to :running_lesson
end
