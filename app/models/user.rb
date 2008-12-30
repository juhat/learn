require 'digest/sha1'

class User < ActiveRecord::Base
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

  def setup_environment
    `mkdir -p #{path}/active/`
    `mkdir -p #{path}/saved/`
  end
  def destroy_environment
    `rm -rf #{path}`
  end
  def start_course
    `tar czvf #{path}/saved/#{Time.now.strftime("%y%m%d%H%M%S")}.tar.gz #{path}/active`
    `rm -rf #{RAILS_ROOT}/courses_saved/#{id}/active`
    `cp -R #{RAILS_ROOT}/testproject_skel #{path}/active`
    `cp #{RAILS_ROOT}/spec/learn_gallery_spec.rb #{path}/active/spec/learn_gallery_spec.rb`
    `cp #{RAILS_ROOT}/spec/spec.opts #{path}/active/spec/spec.opts`
    `cp #{RAILS_ROOT}/spec/spec_helper.rb #{path}/active/spec/spec_helper.rb`
    `cp #{RAILS_ROOT}/spec/learn_story.html #{path}/active/spec/learn_story.html`
    `cp #{RAILS_ROOT}/app/controllers/learn_course_controller.rb #{path}/active/app/controllers/learn_course_controller.rb`
    relink_course
    restart_course
  end
  def relink_course
    `rm -f #{RAILS_ROOT}/testproject`
    `ln -s #{path}/active #{RAILS_ROOT}/testproject`
  end
  def restart_course
    `touch #{path}/active/tmp/restart.txt`
  end
  def course_host
    'user.atti.la'
  end
  def path
    "#{RAILS_ROOT}/courses_saved/#{id}"
  end
  def simple_path
    "courses_saved/#{id}/active"
  end
  
  protected

    def make_activation_code
      self.deleted_at = nil
      self.activation_code = self.class.make_token
    end
end
