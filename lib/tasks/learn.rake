require 'rubygems'
require 'erubis'
require 'digest/md5'

# Task for the first deploy
namespace :moonshine do
  namespace :app do
    desc "Bootstrap vhost generator task"
    task :bootstrap => :environment do
      eruby = Erubis::Eruby.new( 
        File.read( File.join( File.dirname(__FILE__), 'passenger.vhost.erb') )
      )

      (1..100).each do |number|
        key = Digest::MD5.hexdigest("rails-#{number}-#{Time.now.to_s}")
        
        configuration = {
          :domain => "#{key}.#{VHOSTS_URL}",
          :deploy_to => "#{VHOSTS_PATH}/#{key}"
        }
        
        `mkdir -p /tmp/sites-available/`
        
        File.open( "/tmp/sites-available/rails-#{key}", 'w' ) do |e|
          e.write( eruby.result(binding()) )
        end
        
        `sudo mkdir -p /etc/apache2/sites-available`
        `sudo mkdir -p #{VHOSTS_PATH}`
        `sudo mv /tmp/sites-available/rails-#{key} /etc/apache2/sites-available/`
        `sudo a2ensite rails-#{key}`

        `rm -rf /tmp/sites-available`
        
        ResourceUrl.create( :key => configuration[:domain])
        
        puts eruby.result(binding())
      end
    end
  end
end
