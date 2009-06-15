class AddTestData < ActiveRecord::Migration
  def self.up
    puts "DANGER environment dependent migration \n******\n"
    
    # if RAILS_ENV == 'development'
      g = Group.create :name => 'juhat'
      
      u = User.new( :name => 'Attila Juhász', :email => 'juhat@digitus.itk.ppke.hu', :password => 'webtools', :password_confirmation => 'webtools',
        :os_user => 'juhat', :os_gid => 2000 + g.id)
        
      u.register!
      u.update_attribute( :state, 'active' )
      
      u.groups << g
      
      ResourceUrl.create( :url => 'user.atti.la', :type => 'rails')
      Course.create :name => 'Rails 2 tanfolyam', :description => 'Lorem ipsum...'
      Lesson.create :name => 'Rails alapok', :description => 'Lorem ipsum...', :type => 'rails', :course_id => 1
      
      User.first.courses << Course.first
    # end
  end

  def self.down
  end
end
