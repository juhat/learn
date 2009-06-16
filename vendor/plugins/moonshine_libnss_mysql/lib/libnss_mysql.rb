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

    grant =<<EOF
GRANT SELECT(id, login, name, state, os_user, os_gid) 
ON #{database_environment[:database]}.users 
TO #{options[:username] || 'nss'}@localhost;
GRANT SELECT(id, name)
ON #{database_environment[:database]}.groups
TO #{options[:username] || 'nss'}@localhost;
GRANT SELECT(id, user_id, group_id)
ON #{database_environment[:database]}.groups_users
TO #{options[:username] || 'nss'}@localhost;
FLUSH PRIVILEGES;
EOF

    exec "mysql_nss_user",
      :command => "/usr/bin/mysql -u root -p -e \"#{grant}\""
      #,
      # :unless  => "mysqlshow -u#{database_environment[:username]} -p#{database_environment[:password]} #{database_environment[:database]}"
      # ,
      # :before => exec('rake tasks')
  end

end