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

require 'digest/sha1'

class User < ActiveRecord::Base
  has_one :resource_user
  has_one :resource_url
  
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email, :message => 'Szükséges mező.'
  validates_length_of       :email, :within => 6..100, :message => 'Az email cím hossza nem megfelelő.'
  validates_uniqueness_of   :email, :message => 'Az email cím foglalt.'
  validates_format_of       :email, :with => Authentication.email_regex, :message => 'Érvényes email cím lehet.'
  validates_format_of       :email, :with => /\A\w+@digitus\.itk\.ppke\.hu\Z/, :message => "Pillanatnyilag csak egyetemi cím lehet."
  
  after_create :setup_environment
  before_destroy :destroy_environment

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    u = find_in_state :first, :active, :conditions => {:email => email} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end


  def path
    "#{RAILS_ROOT}/courses_saved/#{id}"
  end
  def active_path
    "courses_saved/#{id}/active"
  end
  def setup_environment
    `mkdir -p #{path}/active/`
    `mkdir -p #{path}/saved/`
  end
  def destroy_environment
    `rm -rf #{path}`
  end
  def start_course
    `tar czvf #{path}/saved/#{Time.now.strftime("%y%m%d%H%M%S")}.tar.gz #{path}/active`
    `rm -rf #{active_path}`
    `cp -R #{RAILS_ROOT}/courses/testproject_skel #{active_path}`
    `cp #{RAILS_ROOT}/courses/learn_gallery_spec.rb #{active_path}/spec/learn_gallery_spec.rb`
    `cp #{RAILS_ROOT}/courses/learn_story.html #{active_path}/spec/learn_story.html`

    `cp #{RAILS_ROOT}/spec/spec.opts #{active_path}/spec/spec.opts`
    `cp #{RAILS_ROOT}/spec/spec_helper.rb #{active_path}/spec/spec_helper.rb`
    `cp #{RAILS_ROOT}/app/controllers/learn_course_controller.rb #{active_path}/app/controllers/learn_course_controller.rb`
    relink_course
    # handling user rights
    restart_course_server
    self.resource_url ||= ResourceUrl.first :conditions => ['user_id = NULL']
    self.resource_user ||= ResourceUser.first :conditions => ['user_id = NULL']
  end
  def relink_course
    # it works for development only / it paired with the user.atti.la virtualhost
    `rm -f #{RAILS_ROOT}/testproject`
    `ln -s #{active_path} #{RAILS_ROOT}/testproject`
  end
  def restart_course
    start_course
  end
  def restart_course_server
    `touch #{active_path}/tmp/restart.txt`
  end


  # false in case of problem
  def course_host
    if RAILS_ENV == 'development'
      unless resource_url
        r = ResourceUrl.find(:first, :conditions => [ "user_id = ?", nil], :order => "updated_at DESC")
        if r
          resource_url = r
          return resource_url
        else
          return false
        end
      end
    else
      return 'user.atti.la'
    end
  end
  
  # true if success
  def release_course_host
    if RAILS_ENV == 'production'
      # release the resource
    end
  end
  
  protected
    def make_activation_code
      self.deleted_at = nil
      self.activation_code = self.class.make_token
    end
end
