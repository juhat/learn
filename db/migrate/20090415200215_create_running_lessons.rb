class CreateRunningLessons < ActiveRecord::Migration
  def self.up
    create_table :running_lessons do |t|
      t.integer :lesson_id
      t.integer :user_id
      t.integer :running_course_id
      t.string  :state, :null => :no, :default => 'new'
      t.timestamps
    end
  end

  def self.down
    drop_table :running_lessons
  end
end
