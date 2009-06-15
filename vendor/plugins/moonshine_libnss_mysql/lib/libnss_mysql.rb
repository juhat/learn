module LibnssMysql

  # Define options for this plugin via the <tt>configure</tt> method
  # in your application manifest:
  #
  #   configure(:libnss_mysql => {:foo => true})
  #
  # Then include the plugin and call the recipe(s) you need:
  #
  #  plugin :libnss_mysql
  #  recipe :libnss_mysql
  def libnss_mysql(options = {})
    # define the recipe
    # options specified with the configure method will be 
    # automatically available here in the options hash.
    #    options[:foo]   # => true
    package 'libnss-mysql', :ensure => :installed
    
    file '/etc/nsswitch.conf',
      :mode => '644',
      :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'nsswitch.conf'), binding),
      :require => package('libnss-mysql')

    file '/etc/nss-mysql.conf',
    :mode => '644',
    :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'nss-mysql.conf'), binding),
    :require => package('libnss-mysql')

    # exec 'cp /etc/ssh/sshd_config.new /etc/ssh/sshd_config',
    #   :alias => 'update_sshd_config'
    #   :onlyif => '/usr/sbin/sshd -t -f /etc/ssh/sshd_config.new',
    #   :refreshonly => true, # do nothing until notified
    #   :require => file('/etc/ssh/sshd_config.new'),
    #   :notify => service('ssh')

    grant =<<EOF
GRANT SELECT(id, login, name, state, os_user, os_gid) PRIVILEGES 
ON #{database_environment[:database]}.users
TO #{options[:username] || 'nss'}@localhost
GRANT SELECT(id, name) PRIVILEGES
ON #{database_environment[:database]}.groups
TO #{options[:username] || 'nss'}@localhost
GRANT SELECT(id, user_id, group_id) PRIVILEGES
ON #{database_environment[:database]}.groups_users
TO #{options[:username] || 'nss'}@localhost
FLUSH PRIVILEGES;
EOF
# IDENTIFIED BY '#{options[:password] || 'NssReader'}';
    exec "mysql_user",
      :command => mysql_query(grant),
      :unless  => "mysqlshow -u#{database_environment[:username]} -p#{database_environment[:password]} #{database_environment[:database]}",
      :before => exec('rake tasks')
  end

  private

  # Internal helper to shell out and run a query. Doesn't select a database.
  def mysql_query(sql)
    "/usr/bin/mysql -u root -p -e \"#{sql}\""
  end
  
end