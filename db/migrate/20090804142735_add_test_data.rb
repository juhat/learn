class AddTestData < ActiveRecord::Migration
  def self.up
    puts "DANGER environment dependent migration \n******\n"
    
    if RAILS_ENV == 'development'
      u = User.new :name => 'Attila Juhász', :os_user => 'juhat', :os_group => 'staff', :email => 'juhat@digitus.itk.ppke.hu', :password => 'webtools', :password_confirmation => 'webtools'
      u.register!
      u.update_attribute( :state, 'active' )
      
      ResourceUrl.create( :url => 'user.atti.la', :type => 'rails')
      Course.create :name => 'Rails 2 tanfolyam', :description => 'Lorem ipsum...'
      Lesson.create :name => 'Rails alapok', :description => 'Lorem ipsum...', :type => 'rails', :course_id => 1
      
      User.first.courses << Course.first
    end
  end

  def self.down
  end
end
