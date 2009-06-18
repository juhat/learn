# == Schema Information
# Schema version: 20090617162631
#
# Table name: resource_urls
#
#  id                :integer(4)      not null, primary key
#  url               :string(255)
#  type              :string(255)
#  running_lesson_id :integer(4)
#  created_at        :datetime
#  updated_at        :datetime
#  user_id           :integer(4)
#

class ResourceUrl < ActiveRecord::Base
  belongs_to :running_lesson
  belongs_to :user
end
