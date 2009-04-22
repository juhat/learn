class CreateResourceUrls < ActiveRecord::Migration
  def self.up
    create_table :resource_urls do |t|
      t.string  :url
      t.string :type
      t.timestamps
    end
    
    if RAILS_ENV == 'development'
      ResourceUrl.create( :url => 'user.atti.la', :type => 'rails')
    end
    
  end

  def self.down
    drop_table :resource_urls
  end
end
