# == Schema Information
# Schema version: 20090103144612
#
# Table name: users
#
#  id                        :integer(11)     not null, primary key
#  login                     :string(40)
#  name                      :string(100)     default("")
#  email                     :string(100)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(40)
#  remember_token_expires_at :datetime
#  activation_code           :string(40)
#  activated_at              :datetime
#  state                     :string(255)     default("passive")
#  deleted_at                :datetime
#

require File.dirname(__FILE__) + '/../spec_helper'

describe User, 'course related stuff' do
  it "should give the path of the course"
  it "should give the active_path of the course"
end
