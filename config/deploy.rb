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
set :rails_env, 'development'

# default_run_options[:pty] = true

role :app, "192.168.235.132"
role :web, "192.168.235.132"
role :db,  "192.168.235.132", :primary => true

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
    run "ln -s #{shared_path}/courses #{release_path}/courses"
    run "ln -s #{shared_path}/courses_saved #{release_path}/courses_saved"
  end
  
  desc "Upload courses after cold deploy."
  after "deploy:cold" do
    top.learn.upload_courses
    run "touch #{shared_path}/courses_saved/readme.txt"
    run "cat src/users.sql | sqlite3 #{release_path}/db/#{rails_env}.sqlite3"
    run "cat src/url.sql | sqlite3 #{release_path}/db/#{rails_env}.sqlite3"
    run "rm -f src/*"
  end
end

namespace :learn do
  
  task :bootstrap do
    mkdirs
    update_sudo
    update_umask    
  end
  
  desc "Setup Environment"
  task :setup_env do
    #upgrade
    update_apt_sources
    update_apt_get
    # upgrade_apt_get
    
    #installs
    mkdirs
    install_dev_tools
    install_git
    install_subversion
    install_sqlite3
    install_rails_stack
    install_apache
    install_passenger
    config_passenger
    install_ftp
    
    #populate
    generate_users
  end
  
  desc "Config environment"
  task :config_env do
    top.deploy.setup
    config_vhost
    generate_vhosts
    apache_reload
  end
  
  desc "Sudo, umask setup"
  task :update_sudo do
    sudo "sh -c \"echo '#{user} ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers\""
  end
  
  desc "Update umask"
  task :update_umask do
    sudo "sh -c \"sed -e 's/umask 022/umask 002/' /etc/profile > profile \" "
    sudo "mv profile /etc/profile"
    
    sudo "sh -c \"echo 'umask 002' >> src/bash.bashrc\""
    sudo "sh -c \"cat /etc/bash.bashrc >> src/bash.bashrc\""
    sudo "mv src/bash.bashrc /etc/bash.bashrc"
    
    sudo "sh -c \"echo 'umask 002' >> src/.bashrc\""
    sudo "sh -c \"cat /etc/skel/.bashrc >> src/.bashrc\""
    run "cp src/.bashrc ~/.bashrc"
    # sudo "mv src/.bashrc /etc/skel/.bashrc"
    
    sudo "sh -c \"echo 'Defaults umask=0002' >> /etc/sudoers\""
  end
  
  desc "Basic dirs"
  task :mkdirs do
    run  "mkdir -p src .mc"
  end

  desc "Update apt sources"
  task :update_apt_sources do
    sudo "sh -c \"echo 'deb http://apt.brightbox.net hardy main' >> /etc/apt/sources.list\""
    sudo "wget http://apt.brightbox.net/release.asc -O - | sudo apt-key add -"
  end
  
  desc "Update apt-get sources"
  task :update_apt_get do
    sudo "apt-get update"
  end
  
  desc "Update apt-get sources"
  task :upgrade_apt_get do
    sudo "apt-get upgrade -y"
  end
  
  desc "Install Development Tools and customize #{user}"
  task :install_dev_tools do
    sudo "apt-get install build-essential -y"
    sudo "apt-get install mc -y"
    top.upload 'vendor/stack/mc.ini', '.mc/ini'
  end
  
  desc "Install Git"
  task :install_git do
    sudo "apt-get install git-core git-svn -y"
  end
  
  desc "Install Subversion"
  task :install_subversion do
    sudo "apt-get install subversion -y"
  end
  
  desc "Install MySQL"
  task :install_mysql do
    sudo "apt-get install mysql-server libmysql-ruby -y"
  end
  
  desc "Install SQLite3"
  task :install_sqlite3 do
    sudo "apt-get install sqlite3 libsqlite3-ruby -y"
  end
  
  desc "Install Ruby, Gems, and Rails"
  task :install_rails_stack do
    run <<-CMD
      sudo apt-get install ruby ruby1.8-dev irb ri rdoc libopenssl-ruby1.8 rubygems rubygems1.8 -y  &&
      sudo gem install rails --no-ri --no-rdoc  &&
      sudo gem install rails --no-ri --no-rdoc --version 2.1.0  &&
      sudo gem install hpricot
    CMD
  end
  
  desc "Install Apache"
  task :install_apache do
    sudo "apt-get install apache2 apache2.2-common apache2-mpm-worker
          apache2-utils libexpat1 apache2-prefork-dev libapr1-dev -y"
    sudo "chown :sudo /var/www"
    sudo "chmod g+w /var/www"
  end
  
  desc "Install Passenger"
  task :install_passenger do
    sudo "apt-get install libapache2-mod-passenger"
  end
  
  desc "Configure Passenger"
  task :config_passenger do
    sudo "sh -c \"echo 'LoadModule passenger_module /mod_passenger.so' > 
          /etc/apache2/mods-available/passenger.load \""
  end
  
  desc "Install ftp"
  task :install_ftp do
    sudo "apt-get install vsftpd -y"
    sudo "mv /etc/vsftpd.conf /etc/vsftpd.conf.bak"
    ftp_config =<<-EOF
listen=YES
local_enable=YES
write_enable=YES
local_umask=022
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
    EOF
    put ftp_config, "src/ftp_config"
    sudo "mv src/ftp_config /etc/vsftpd.conf"
    sudo "/etc/init.d/vsftpd restart"
  end
  
  desc "Configure main VHost"
  task :config_vhost do
    vhost_config =<<-EOF
NameVirtualHost *
<VirtualHost *>
  ServerName learn.atti.la
  DocumentRoot #{deploy_to}/current/public
  RailsEnv #{rails_env}
  PassengerMaxInstancesPerApp 2
</VirtualHost>
    EOF
    put vhost_config, "src/vhost_config"
    sudo "mv src/vhost_config /etc/apache2/sites-available/#{application}"
    sudo "a2ensite #{application}"
    sudo "a2dissite default"
    # sudo "rm /etc/apache2/sites-available/default"
  end
  
  desc "Reload Apache"
  task :apache_reload do
    sudo "/etc/init.d/apache2 reload"
  end
  
  desc "Generate users"
  task :generate_users do
    sudo "sh -c \"find /home/#{user}/. -type d -exec chmod 771 {} \\; \""
    # sudo "sh -c \"find /home/#{user}/. -type f -exec chmod 664 {} \\; \"" 
    sudo "chmod 771 /home/#{user}"
    
    sudo "useradd -m test"
    sudo "sh -c \"find /home/test/. -type d -exec chmod 771 {} \\; \""
    # sudo "sh -c \"find /home/test/. -type f -exec chmod 664 {} \\; \"" 
    sudo "chmod 771 /home/test"
    sudo "adduser juhat test"
    
    (1..10).each do |number|
      sudo "useradd -m user#{number}"
      sudo "sh -c \"find /home/user#{number}/. -type d -exec chmod 771 {} \\; \""
      # sudo "sh -c \"find /home/user#{number}/. -type f -exec chmod 664 {} \\; \""
      sudo "chmod 771 /home/user#{number}"
      sudo "adduser juhat user#{number}"
      run "echo \"INSERT INTO 'server_resources' ('type', 'key', 'status') VALUES('user', 'user#{number}', 'free');\" >> src/users.sql"
    end
  end
  
  desc "Generate vhosts"
  task :generate_vhosts do
    run "#{sudo :as => "test"} rails /home/test/basic_rails"
    sudo "sh -c \"find /home/test/. -type d -exec chmod 771 {} \\; \""
    
    vhost_config =<<-EOF
<VirtualHost *>
  ServerName rails.test1.krc.hu
  DocumentRoot /home/test/public_html/public
  RailsEnv development
  PassengerMaxInstancesPerApp 1
  PassengerPoolIdleTime 120
</VirtualHost>
    EOF
    put vhost_config, "src/vhost_config"
    
    (1..10).each do |number|
      key = Digest::MD5.hexdigest("rails_#{number}")
      run "ln -s /home/test/basic_rails /home/test/rails_#{key}"
      sudo "sh -c \"sed -e 's/rails.test1.krc.hu/rails_#{key}.test1.krc.hu/' src/vhost_config > src/vhost_config.bak \" "
      sudo "sh -c \"sed -e 's/\\/home\\/test\\/public_html\\/public/\\/home\\/test\\/rails_#{key}\\/public/' src/vhost_config.bak > src/vhost_config.bak2 \" "
      sudo "mv src/vhost_config.bak2 /etc/apache2/sites-available/rails_#{key}"
      sudo "rm -f src/vhost_config.bak"
      run "echo \"INSERT INTO 'server_resources' ('type', 'key', 'status') VALUES('url', 'rails_#{key}', 'free');\" >> src/url.sql"
      sudo "a2ensite rails_#{key}"
    end
      sudo "rm -f src/vhost_config"
  end
  
  desc "Upload courses"
  task :upload_courses do
    `cd ../courses && tar -czvf ../courses.tar.gz *`
    top.upload '../courses.tar.gz', 'src/courses.tar.gz'
    run "cd #{shared_path}/courses/ && tar -zxvf /home/#{user}/src/courses.tar.gz"
    run "sh -c \"find #{shared_path}/courses/. -type d -exec chmod 770 {} \\; \""
    run "sh -c \"find #{shared_path}/courses/. -type f -exec chmod 660 {} \\; \""
    run "rm -f src/courses.tar.gz"
  end
  
  desc "Backup Learn system."
  task :backup, :roles => :app do
    ts = Time.now.utc.strftime("%Y%m%d%H%M%S")
    `mkdir -p ../archives/Learn/#{ts}`
    `rm -f ../archives/Learn/current`
    `cd ../archives/Learn && ln -s #{ts} current`
    
    run <<-CMD
      cd #{shared_path}   &&
      tar -czvf /home/#{user}/src/courses_saved.tar.gz courses_saved/*  &&
      cd log  &&
      tar -czvf /home/#{user}/src/log.tar.gz ./*  &&
      cd ../db  &&
      tar -czvf /home/#{user}/src/db.tar.gz ./*
    CMD
    get "/home/#{user}/src/log.tar.gz", "../archives/Learn/#{ts}/log.tar.gz"
    `cd ../archives/Learn/#{ts}/  && tar -zxvf log.tar.gz  && rm -f log.tar.gz` 
    get "/home/#{user}/src/db.tar.gz", "../archives/Learn/#{ts}/db.tar.gz"
    `cd ../archives/Learn/#{ts}/  && tar -zxvf db.tar.gz  && rm -f db.tar.gz` 
    get "/home/#{user}/src/courses_saved.tar.gz", "../archives/Learn/#{ts}/courses_saved.tar.gz"
    
    run "rm -f /home/#{user}/src/*"
  end
end