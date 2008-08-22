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
  end

  def self.down
    drop_table :courses
  end
end
