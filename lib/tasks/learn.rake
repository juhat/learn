namespace :learn do
  desc "Put resources into the db."
  task(:import_resources => :environment) do
    puts 'Processed URLs: '
    File.new("#{RAILS_ROOT}/db/urls.txt", 'r').each() do |line|
      ResourceUrl.create :key=> line.strip
      print ' ' + line.strip
    end
  end
end