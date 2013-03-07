class CreateApnsOnRails < ActiveRecord::Migration
  def self.up
    create_table "apn_apps", :force => true do |t|
      t.string   "name"
      t.string   "bundle_identifier"
      t.text     "cert"
      t.datetime "created_at",        :null => false
      t.datetime "updated_at",        :null => false
    end
    
    add_index "apn_apps", ["bundle_identifier"], :name => "index_apn_apps_on_bundle_identifier"
    
    
    create_table "apn_devices", :force => true do |t|
      t.string   "name"
      t.string   "system_name"
      t.string   "system_version"
      t.string   "model"
      t.string   "app_version"
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
      t.datetime "sent_at"
      t.datetime "created_at",        :null => false
      t.datetime "updated_at",        :null => false
      t.text     "custom_properties"
      t.string   "action_key"
    end

    add_index "apn_notifications", ["device_id"], :name => "index_apn_notifications_on_device_id"

  end

  def self.down
    drop_table "apn_apps"
    drop_table "apn_devices"
    drop_table "apn_notifications"
  end
end