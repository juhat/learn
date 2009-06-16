require 'rubygems'
require 'erubis'
require 'digest/md5'

# Task for the first deploy
namespace :moonshine do
  namespace :app do
    desc "Bootstrap vhost generator task"
    task :bootstrap => :environment do
    end
  end
end
