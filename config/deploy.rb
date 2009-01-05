# LEARN system installer
require 'digest/md5'

set :application, "Learn"
set :user, "juhat"
set :password, "juhat"
set :admin_runner, "juhat"

set :scm, :git
set :repository,  "file:///users/juhat/Sites/l/.git/"
set :deploy_via, :copy

set :deploy_to, "/home/juhat/#{application}"
set :shared_children, %w(system log pids courses db courses_saved)
set :rails_env, 'production'

role :app, "192.168.235.133"
role :web, "192.168.235.133"
role :db,  "192.168.235.133", :primary => true


# Deploy namespace
namespace :deploy do

  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
  
  desc "Link shared files."
  before "deploy:finalize_update" do
    sudo "sh -c \"find /home/#{user}/. -type d -exec chmod 771 {} \\; \""
    
    run "rm -f #{release_path}/db/production.sqlite3"
    run "rm -f #{release_path}/db/development.sqlite3"
    run "ln -s #{shared_path}/db/production.sqlite3 #{release_path}/db/production.sqlite3"
    run "ln -s #{shared_path}/db/development.sqlite3 #{release_path}/db/development.sqlite3"
    
    run "rm -rf #{release_path}/courses"
    run "ln -s #{shared_path}/courses #{release_path}/courses"
    run "rm -rf #{release_path}/courses_saved"
    run "ln -s #{shared_path}/courses_saved #{release_path}/courses_saved"
    
    run "rm -rf #{release_path}/public/system"
    run "ln -s #{shared_path}/system #{release_path}/public/system"
  end

  desc "Move resource files"
  after "deploy:setup" do
    run "cp src/users.txt #{shared_path}/db"
    run "cp src/urls.txt #{shared_path}/db"
  end
  
  desc "Upload resources."
    task :import_resources do
    run "cd #{release_path}; rake learn:import_resources RAILS_ENV=#{rails_env}"
  end
end



namespace :learn do
  
  desc "Setup Environment"
  task :setup do
    # update_apt_get
    # upgrade_apt_get
    
    # install the software stack
    mkdirs
    install_stack

    # Populate with student users
    config_learn_vhost

    generate_users
    generate_vhosts

    top.deploy.setup    
    apache_reload
  end
  
  desc "Basic dirs"
  task :mkdirs do
    run  "mkdir -p src .mc"
  end
  
  desc "Update apt-get sources"
  task :update_apt_get do
    sudo "apt-get update"
  end
  
  desc "Update apt-get sources"
  task :upgrade_apt_get do
    sudo "apt-get upgrade -y"
  end

  desc "Install software stack"
  task :install_stack do
    #mysql-server libmysql-ruby
    #build-essential  subversion libopenssl-ruby1.8 
    # rubygems rubygems1.8
    #apache2-suexec
    sudo <<-CMD
      apt-get install -y
        mc build-essential
        git-core
        ruby ruby1.8 irb irb1.8 ruby1.8-dev libreadline-ruby libreadline-ruby1.8 libopenssl-ruby libopenssl-ruby1.8
        sqlite3 libsqlite3-ruby
        libapache2-mod-passenger
    CMD
    sudo "a2enmod rewrite"
    
    run <<-CMD
      cd src &&
      wget http://rubyforge.org/frs/download.php/45905/rubygems-1.3.1.tgz &&
      tar xvzf rubygems-1.3.1.tgz &&
      cd rubygems-1.3.1 &&
      sudo ruby setup.rb &&
      sudo ln -s /usr/bin/gem1.8 /usr/local/bin/gem
      cd ~
    CMD
    sudo "gem sources -a http://gems.github.com"
    
    sudo "gem install rails --no-ri --no-rdoc"
    sudo "gem install rails --no-ri --no-rdoc --version 2.1.0"
    sudo "gem install hpricot rspec rspec-rails rubyist-aasm --no-ri --no-rdoc"
    
    top.upload 'vendor/stack/mc.ini', '.mc/ini'
  end

  desc "Configure main VHost"
  task :config_learn_vhost do
    vhost_config =<<-EOF
NameVirtualHost *:80
<VirtualHost *:80>
  ServerName learn.atti.la
  DocumentRoot #{deploy_to}/current/public
  RailsEnv #{rails_env}
  PassengerMaxInstancesPerApp 2
  RewriteEngine On
</VirtualHost>
    EOF
    put vhost_config, "src/vhost_config"
    sudo "mv src/vhost_config /etc/apache2/sites-available/#{application}"
    sudo "a2ensite #{application}"
    sudo "a2dissite default"
  end
  
  desc "Reload Apache"
  task :apache_reload do
    sudo "/etc/init.d/apache2 reload"
  end
  
  desc "Generate users"
  task :generate_users do
    # sudo "sh -c \"find /home/#{user}/. -type d -exec chmod 771 {} \\; \""
    # sudo "sh -c \"find /home/#{user}/. -type f -exec chmod 664 {} \\; \"" 
    sudo "chmod 771 /home/#{user}"
    
    sudo "useradd test" # -m for creating home
    # sudo "sh -c \"find /home/test/. -type d -exec chmod 771 {} \\; \""
    # sudo "sh -c \"find /home/test/. -type f -exec chmod 664 {} \\; \"" 
    # sudo "chmod 771 /home/test"
    sudo "adduser juhat test"
    
    (1..10).each do |number|
      sudo "useradd user#{number}"
      # sudo "sh -c \"find /home/user#{number}/. -type d -exec chmod 771 {} \\; \""
      # sudo "sh -c \"find /home/user#{number}/. -type f -exec chmod 664 {} \\; \""
      # sudo "chmod 771 /home/user#{number}"
      sudo "adduser juhat user#{number}"
      run "echo \"user#{number}\" >> src/users.txt"
    end
  end
  
  desc "Generate vhosts"
  task :generate_vhosts do
    # run "#{sudo :as => "test"} rails /home/test/basic_rails"
    # sudo "sh -c \"find /home/test/. -type d -exec chmod 771 {} \\; \""
    
    vhost_config =<<-EOF
<VirtualHost *>
  ServerName rails.e-learn.hu
  DocumentRoot /home/test/public_html/public
  RailsEnv development
  PassengerMaxInstancesPerApp 1
  PassengerPoolIdleTime 120
  RewriteEngine On
</VirtualHost>
    EOF
    put vhost_config, "src/vhost_config"
    
    (1..10).each do |number|
      key = Digest::MD5.hexdigest("rails_#{number}")
      # run "ln -s /home/test/basic_rails /home/test/rails_#{key}"
      sudo "sh -c \"sed -e 's/rails.e-learn.hu/rails_#{key}.e-learn.hu/' src/vhost_config > src/vhost_config.bak \" "
      sudo "sh -c \"sed -e 's/\\/home\\/test\\/public_html\\/public/\\/home\\/test\\/rails_#{key}\\/public/' src/vhost_config.bak > src/vhost_config.bak2 \" "
      sudo "mv src/vhost_config.bak2 /etc/apache2/sites-available/rails_#{key}"
      sudo "rm -f src/vhost_config.bak"
      run "echo \"rails_#{key}\" >> src/urls.txt"
      sudo "a2ensite rails_#{key}"
    end
      sudo "rm -f src/vhost_config"
  end
end