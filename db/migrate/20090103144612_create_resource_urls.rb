class CreateResourceUrls < ActiveRecord::Migration
  def self.up
    create_table :resource_urls do |t|
      t.string  :url
      t.timestamps
    end
    
    if RAILS_ENV == 'development'
      ResourceUrl.create( :url => 'user.atti.la' )
    end
    
  end

  def self.down
    drop_table :resource_urls
  end
end
