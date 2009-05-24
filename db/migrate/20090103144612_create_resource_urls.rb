class CreateResourceUrls < ActiveRecord::Migration
  def self.up
    create_table :resource_urls do |t|
      t.string  :url
      t.string :type
      t.integer :running_lesson_id
      t.timestamps
    end
  end

  def self.down
    drop_table :resource_urls
  end
end
