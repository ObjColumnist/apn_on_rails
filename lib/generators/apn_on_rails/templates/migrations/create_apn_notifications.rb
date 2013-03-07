class CreateApnNotifications < ActiveRecord::Migration # :nodoc:
  
  def self.up

    create_table :apn_notifications do |t|
      t.integer :device_id, :null => false
      t.string :sound
      t.string :body, :size => 150
      t.integer :badge
      t.datetime :sent_at
      t.timestamps
    end
    
    add_index :apn_notifications, :device_id
  end

  def self.down
    drop_table :apn_notifications
  end
  
end