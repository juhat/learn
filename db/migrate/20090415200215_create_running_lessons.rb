class CreateRunningLessons < ActiveRecord::Migration
  def self.up
    create_table :running_lessons do |t|
      t.integer :lesson_id
      t.integer :user_id
      t.integer :resource_url_id
      t.timestamps
    end
  end

  def self.down
    drop_table :running_lessons
  end
end
