class CreateRunningCourses < ActiveRecord::Migration
  def self.up
    create_table :running_courses do |t|
      t.integer :course_id
      t.integer :user_id
      t.string  :state, :null => :no, :default => 'new'
      t.timestamps
    end
  end

  def self.down
    drop_table :running_courses
  end
end
