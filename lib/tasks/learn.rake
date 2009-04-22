# Task for the first deploy
namespace :moonshine do
  namespace :app do
    desc "Overwrite this task in your app if you have any bootstrap tasks that need to be run"
    task :bootstrap => :environment do
      puts "### HELLO WORLD"
    end
  end
end
