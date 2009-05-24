class CreateLessons < ActiveRecord::Migration
  def self.up
    create_table :lessons do |t|
      t.string :type
      t.string :name
      t.text :description
      t.integer :course_id

      t.timestamps
    end
  end

  def self.down
    drop_table :lessons
  end
end
