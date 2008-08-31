class ServerResources < ActiveRecord::Migration
  def self.up
    create_table :server_resources do |t|
      t.string :type
      t.string :key
      t.string :status
      # t.timestamps
    end
  end

  def self.down
    drop_table :server_resources
  end
end
