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
      t.column :os_group,                  :string
      t.column :os_secret,                  :string
    end
    add_index :users, :login, :unique => true
    
    if RAILS_ENV == 'development'
      u = User.new :name => 'Attila Juhász', :os_user => 'juhat', :os_group => 'staff', :email => 'juhat@digitus.itk.ppke.hu', :password => 'webtools', :password_confirmation => 'webtools'
      u.register!
      u.update_attribute( :state, 'active' )
    end
  end

  def self.down
    drop_table "users"
  end
end
