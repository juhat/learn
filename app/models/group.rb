# == Schema Information
# Schema version: 20090617162631
#
# Table name: groups
#
#  id   :integer(4)      not null, primary key
#  name :string(255)
#

class Group < ActiveRecord::Base
  has_and_belongs_to_many :users
  
  has_one :base_user, :class_name => "User", :foreign_key => :os_gid
  
  validates_presence_of :name
end
