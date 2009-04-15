class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
    
    if RAILS_ENV == 'development'
      Course.create :name => 'Rails 2 tanfolyam', :description => 'Lorem ipsum...'
    end
  end

  def self.down
    drop_table :courses
  end
end
