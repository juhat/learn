class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column :login,                     :string, :limit => 40
      t.column :name,                      :string, :limit => 100, :default => '', :null => true
      t.column :email,                     :string, :limit => 100
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string, :limit => 40
      t.column :remember_token_expires_at, :datetime
      t.column :activation_code,           :string, :limit => 40
      t.column :activated_at,              :datetime
      t.column :state,                     :string, :null => :no, :default => 'passive'
      t.column :deleted_at,                :datetime
      t.column :os_user,                  :string
      t.column :os_gid,                   :integer
      t.column :os_secret,                  :string

      # t.column :homedir, :string
      # t.column :shell, :string

      # t.column :uid, :integer
      # t.column :gid, :integer
    end
    add_index :users, :login, :unique => true
    
    execute "ALTER TABLE users AUTO_INCREMENT = 1000;"
  end

  def self.down
    drop_table "users"
  end
end
