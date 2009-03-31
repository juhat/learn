# == Schema Information
# Schema version: 20090103144612
#
# Table name: resource_users
#
#  id         :integer(11)     not null, primary key
#  key        :string(255)
#  user_id    :integer(11)
#  created_at :datetime
#  updated_at :datetime
#

class ResourceUser < ActiveRecord::Base
  belongs_to :user
end
