# == Schema Information
# Schema version: 20090617162631
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
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
#  os_user                   :string(255)
#  os_gid                    :integer(4)
#  os_secret                 :string(255)
#

require File.dirname(__FILE__) + '/../spec_helper'

describe User, 'course related stuff' do
  it "should give the paths of the course"
  it "should setup and delete dirs around user lifecicle"
  it "should start a new course"
  it "should stop a course"
  it "should restart course server"
  it "should relink course dir for mod_rails"
  it "should associate and release course url"
  it "should associate and release course user"
end
