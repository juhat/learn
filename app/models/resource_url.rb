# == Schema Information
# Schema version: 20090415162021
#
# Table name: resource_urls
#
#  id         :integer(4)      not null, primary key
#  key        :string(255)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class ResourceUrl < ActiveRecord::Base
  belongs_to :user
end
