class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.string :name
      t.string :author
      t.text :description
      t.integer :price
      t.text :text

      t.timestamps
    end
    Course.create :name=>'Rails', :author=>'Juhasz Attila'
  end

  def self.down
    drop_table :courses
  end
end
