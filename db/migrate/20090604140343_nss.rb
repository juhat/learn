class Nss < ActiveRecord::Migration
  def self.up
    create_table "groups", :force => true do |t|
      t.column :name, :string
    end
    
    create_table "groups_users", :id => nil do |t|
      t.integer 'user_id'
      t.integer 'group_id'
    end
  end

  def self.down
    drop_table "groups"
    drop_table "groups_users"
  end
end
