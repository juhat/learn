class CreateLessons < ActiveRecord::Migration
  def self.up
    create_table :lessons do |t|
      t.string :type
      t.string :name
      t.text :description
      t.integer :course_id

      t.timestamps
    end

    if RAILS_ENV == 'development'
      Lesson.create :name => 'Rails alapok', :description => 'Lorem ipsum...', :type => 'rails', :course_id => 1
    end
  end

  def self.down
    drop_table :lessons
  end
end
