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

require 'digest/sha1'
require 'etc' 
require 'fileutils'
require 'digest/md5'

class User < ActiveRecord::Base
  has_many :running_courses
  has_many :courses, :through => :running_courses

  has_many :running_lessons
  has_many :lessons, :through => :running_lessons
  
  has_and_belongs_to_many :groups
  belongs_to :base_group, :class_name => "Group", :foreign_key => :os_gid
  
  has_one :resource_url, :autosave => true
  
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
  # validates_format_of       :email, :with => /\A\w+@digitus\.itk\.ppke\.hu\Z/, :message => "Pillanatnyilag csak egyetemi cím lehet."
  # validates_presence_of     :os_user, :os_secret, :base_group
  
  after_create :setup_environment
  after_destroy :destroy_environment

  #
  # Login system
  #

  # prevents a user from submitting a crafted form that bypasses activation
  attr_accessible :login, :email, :name, :password, :password_confirmation, :os_user, :os_gid, :os_secret

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
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


  #
  # Course related codes 
  # 
  def setup_environment
    update_attributes(
      :os_user => "user#{ id }",
      :os_secret => Digest::MD5.hexdigest("#{ os_user } #{ Time.now.to_s } #{ rand(1024) }")
    )
    self.create_base_group( :name => "group#{ id }" ) unless base_group
    save!
  end

  def destroy_environment
    if Rails.env == 'production'
      `sudo rm -rf #{ home_path }`
    end
  end

  def home_path
    File.join( USER_DIR, os_user )
  end

  def path
    File.join( home_path, os_secret)
  end
  
  def lesson_path
    File.join( path, 'rails')
  end
  
  def start_learn
    if RAILS_ENV == 'production'
      run_code "sudo mkdir -p #{ path }"
      # run_code "sudo chmod 755 #{ home_path }"
      # run_code "sudo chmod 711 #{ path }"
      run_code "sudo chown #{ os_user }:#{ base_group.name } #{ path }"

      run_code "sudo rm -rf #{ lesson_path }"
      run_code "sudo cp -R /srv/rails #{ lesson_path }"
      # run_code "sudo mkdir #{ lesson_path }"
      # run_code "sudo cp #{RAILS_ROOT}/spec/learn_gallery_spec.rb #{ lesson_path }/spec/learn_gallery_spec.rb"
      # run_code "sudo cp #{RAILS_ROOT}/spec/spec.opts #{lesson_path}/spec/spec.opts"
      # run_code "sudo cp #{RAILS_ROOT}/spec/spec_helper.rb #{lesson_path}/spec/spec_helper.rb"
      run_code "sudo chown -R #{ os_user }:#{ base_group.name } #{ lesson_path }"
    end
    
    if self.resource_url
      run_code "sudo rm /srv/vhosts/#{self.resource_url.url}" if RAILS_ENV == 'production'
      self.resource_url = nil 
    end
    self.resource_url = ResourceUrl.first :conditions => { :user_id => nil }, :order => 'updated_at ASC'
    
    if RAILS_ENV == 'production'
      run_code "sudo rm /srv/vhosts/#{self.resource_url.url}"
      run_code "sudo ln -s #{lesson_path} /srv/vhosts/#{self.resource_url.url}"
    end
  end
  
  protected
    def make_activation_code
      self.deleted_at = nil
      self.activation_code = self.class.make_token
    end
    
    def run_code( code )
      logger.info( 'RUN > ' + code )
      rsp = `#{ code }`
      unless $?.to_i
        logger.info( "RETURN 0 > #{rsp}" )
      else
        logger.error( "RETURN #{$?.to_i} > #{rsp}" )
      end      
    end
end
