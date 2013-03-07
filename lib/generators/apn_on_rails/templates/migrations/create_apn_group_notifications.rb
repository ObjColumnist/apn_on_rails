class CreateApnGroupNotifications < ActiveRecord::Migration # :nodoc:
  
  def self.up

    create_table :apn_group_notifications do |t|
      t.integer :group_id, :null => false
      t.string :sound
      t.string :body, :size => 150
      t.integer :badge
      t.text :custom_properties
      t.datetime :sent_at
      t.timestamps
    end
    
    add_index :apn_group_notifications, :group_id
  end

  def self.down
    drop_table :apn_group_notifications
  end
  
end