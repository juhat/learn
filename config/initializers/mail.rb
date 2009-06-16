# require "smtp_tls"
# mailer_config = File.open("#{RAILS_ROOT}/config/mailer.yml")
# mailer_options = YAML.load(mailer_config)
# ActionMailer::Base.smtp_settings = mailer_options

ActionMailer::Base.smtp_settings = {
    :tls => true,
    :address => "smtp.gmail.com",
    :port => "587",
    :domain => "atti.la",
    :authentication => :plain,
    :user_name => "learn@atti.la",
    :password => "webtools" 
  }
