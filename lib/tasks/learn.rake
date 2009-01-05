namespace :learn do
  desc "Put resources into the db."
  task(:import_resources => :environment) do
    puts 'Processed URLs: '
    File.new("#{RAILS_ROOT}/db/urls.txt", 'r').each() do |line|
      ResourceUrl.create :key=> line.strip
      print ' ' + line.strip
    end
    puts "\nProcessed USERs: "
    File.new("#{RAILS_ROOT}/db/users.txt", 'r').each() do |line|
      ResourceUser.create :key=> line.strip
      print  ' ' + line.strip
    end
    puts
  end
end