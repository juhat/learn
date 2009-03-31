class CreateResourceUsers < ActiveRecord::Migration
  def self.up
    create_table :resource_users do |t|
      t.string  :key
      t.integer :user_id
      t.timestamps
    end
    
    if RAILS_ENV == 'development'
      ResourceUser.create( :key => 'juhat' )
    end
    
  end

  def self.down
    drop_table :resource_users
  end
end
