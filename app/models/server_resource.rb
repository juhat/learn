class ServerResource < ActiveRecord::Base
  validates_presence_of :key
  validates_uniqueness_of :key
  validates_presence_of :status
  validates_presence_of :type
end