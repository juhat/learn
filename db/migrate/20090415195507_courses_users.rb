class CoursesUsers < ActiveRecord::Migration
  def self.up
    create_table :courses_users, :id => false do |t|
      t.integer :course_id
      t.integer :user_id
    end
    
    if RAILS_ENV == 'development'
      User.first.courses << Course.first
    end
  end

  def self.down
  end
end
