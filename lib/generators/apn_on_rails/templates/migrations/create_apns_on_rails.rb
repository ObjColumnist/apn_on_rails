class CreateApnsOnRails < ActiveRecord::Migration
  def self.up
    create_table "apn_apps", :force => true do |t|
      t.text     "cert"
      t.datetime "created_at",        :null => false
      t.datetime "updated_at",        :null => false
    end
        
    
    create_table "apn_devices", :force => true do |t|
      t.string   "token",              :null => false
      t.datetime "created_at",         :null => false
      t.datetime "updated_at",         :null => false
      t.integer  "app_id"
      t.datetime "last_registered_at"
    end

    add_index "apn_devices", ["token"], :name => "index_apn_devices_on_token"

    create_table "apn_notifications", :force => true do |t|
      t.integer  "device_id",         :null => false
      t.string   "sound"
      t.string   "body"
      t.integer  "badge"
      t.string   "launch_image"
      t.string   "action_localized_key"
      t.string   "localized_key"
      t.text     "localized_key_arguments"
      t.text     "custom_payloads"
      t.datetime "sent_at"
      t.datetime "created_at",        :null => false
      t.datetime "updated_at",        :null => false
    end

    add_index "apn_notifications", ["device_id"], :name => "index_apn_notifications_on_device_id"

  end

  def self.down
    drop_table "apn_apps"
    drop_table "apn_devices"
    drop_table "apn_notifications"
  end
end