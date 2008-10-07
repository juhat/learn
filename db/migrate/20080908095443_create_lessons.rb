class CreateLessons < ActiveRecord::Migration
  def self.up
    create_table :lessons do |t|
      t.integer :course_id
      t.integer :position
      t.string :name
      t.timestamps
    end
    Lesson.create :name=>'Rails bevezeto', :course_id=>1, :position=>1
    Lesson.create :name=>'Migraciok', :course_id=>1, :position=>3
    Lesson.create :name=>'RJS template', :course_id=>1, :position=>2
  end

  def self.down
    drop_table :lessons
  end
end
