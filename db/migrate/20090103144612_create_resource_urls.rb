class CreateResourceUrls < ActiveRecord::Migration
  def self.up
    create_table :resource_urls do |t|
      t.string  :key
      t.integer :user_id
      t.timestamps
    end
    
    if RAILS_ENV == 'development'
      ResourceUrl.create( :key => 'user.atti.la', :user_id => 1 )
    end
    
  end

  def self.down
    drop_table :resource_urls
  end
end
