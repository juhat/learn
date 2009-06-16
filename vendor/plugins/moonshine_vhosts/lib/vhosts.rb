require 'digest/md5'

module Vhosts

  # Define options for this plugin via the <tt>configure</tt> method
  # in your application manifest:
  #
  #   configure(:vhosts => {:foo => true})
  #
  # Then include the plugin and call the recipe(s) you need:
  #
  #  plugin :vhosts
  #  recipe :vhosts
  def vhosts(options = {})
    # define the recipe
    # options specified with the configure method will be 
    # automatically available here in the options hash.
    #    options[:foo]   # => true
    file '/etc/apache2/sites-available/rails-courses',
      :mode => '644',
      :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'passenger.vhost.erb'), binding),
      :notify => service('apache2')
    
    file options[:docroot], 
      :ensure => :directory,
      :mode => '775'
  end
  
end