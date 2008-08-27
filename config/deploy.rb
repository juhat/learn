default_run_options[:pty] = true

set :application, "Learn"
set :scm, :git
set :repository,  "file:///users/juhat/Sites/l/.git/"
set :deploy_via, :copy

set :deploy_to, "/home/juhat/#{application}"
set :user, "juhat"
set :password, "juhat"
set :admin_runner, "juhat" 

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
  
  desc "Link shared files"
  #task :before_symlink do
  before "deploy:migrate" do
    run "ln -s #{shared_path}/db/production.sqlite3 #{release_path}/db/production.sqlite3"
  end
  
  desc "shared dirs"
  after "deploy:setup" do
    run "mkdir -p #{shared_path}/db #{shared_path}/uploads"
  end
end

namespace :learn do
  desc "Setup Environment"
  task :setup_env do
    update_sudo
    update_apt_sources
    update_apt_get
    upgrade_apt_get
    install_dev_tools
    install_git
    install_subversion
    install_sqlite3
    install_rails_stack
    install_apache
    install_passenger
    config_passenger
    generate_users
    apache_reload
  end
  
  desc "Config environment"
  task :config_env do
    top.deploy.setup
    config_vhost
    generate_vhosts
    apache_reload
  end
  
  desc "Sudo setup"
  task :update_sudo do
    sudo "sh -c \"echo '#{user} ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers\""
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
  
  desc "Install Development Tools"
  task :install_dev_tools do
    sudo "apt-get install build-essential -y"
    sudo "apt-get install mc -y"
    run  "mkdir src"
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
      sudo gem install rails --no-ri --no-rdoc
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
  
  desc "Configure main VHost"
  task :config_vhost do
    vhost_config =<<-EOF
NameVirtualHost *
<VirtualHost *>
  ServerName auto.atti.la
  DocumentRoot #{deploy_to}/current/public
  # RailsEnv development
</VirtualHost>
    EOF
    run "mkdir -p /home/#{user}/Learn/public"
    run "echo 'hello LEARNER' >  /home/#{user}/Learn/public/index.html "
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
    sudo "mkdir -p /etc/skel/public_html"
    sudo "sh -c \"sed -e 's/umask 022/umask 002/' /etc/profile > profile \" "
    sudo "mv profile /etc/profile"
    
    sudo "useradd -m test"
    sudo "sh -c \"find /home/test/. -type d -exec chmod 775 {} \\; \""
    sudo "sh -c \"find /home/test/. -type f -exec chmod 664 {} \\; \""
    run "#{sudo :as => "test"} mkdir -p -m 775 /home/test/public_html/public"
    sudo "chmod 775 /home/test/public_html"
    sudo "chmod 775 /home/test"
    sudo "adduser juhat test"
    
    (1..3).each do |number| 
      sudo "useradd -m user#{number}"
      sudo "sh -c \"find /home/user#{number}/. -type d -exec chmod 775 {} \\; \""
      sudo "sh -c \"find /home/user#{number}/. -type f -exec chmod 664 {} \\; \""
      sudo "chmod 775 /home/user#{number}/public_html"      
      sudo "chmod 775 /home/user#{number}"
      sudo "adduser juhat user#{number}"
    end
  end
  
  desc "Generate vhosts"
  task :generate_vhosts do
    run "#{sudo :as => "test"} echo 'subsite' > /home/test/public_html/public/index.html"

    vhost_config =<<-EOF
<VirtualHost *>
  ServerName rails.test1.krc.hu
  DocumentRoot /home/test/public_html/public
  RailsEnv development
</VirtualHost>
    EOF
    put vhost_config, "src/vhost_config"
    
    (1..3).each do |number|
      run "ln -s /home/test/public_html /home/test/rails_#{number}"
      sudo "sh -c \"sed -e 's/rails.test1.krc.hu/rails#{number}.test1.krc.hu/' src/vhost_config > src/vhost_config.bak \" "
      sudo "sh -c \"sed -e 's/\\/home\\/test\\/public_html\\/public/\\/home\\/test\\/rails_#{number}\\/public/' src/vhost_config.bak > src/vhost_config.bak2 \" "
      sudo "mv src/vhost_config.bak2 /etc/apache2/sites-available/rails_#{number}"
      sudo "rm src/vhost_config.bak"
      
      sudo "a2ensite rails_#{number}"
    end
  end
end