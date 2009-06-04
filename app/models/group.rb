# == Schema Information
# Schema version: 20090804142735
#
# Table name: groups
#
#  id   :integer(4)      not null, primary key
#  name :string(255)
#

class Group < ActiveRecord::Base
  has_and_belongs_to_many :users
  
  validates_presence_of :name
end
