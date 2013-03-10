class CreateApnsOnRails < ActiveRecord::Migration
  def self.up
    create_table "apns_apps", :force => true do |t|
      t.string   "bundle_identifier"
      t.string   "platform"
      t.string   "environment"
      t.text     "certificate"
      t.datetime "created_at",        :null => false
      t.datetime "updated_at",        :null => false
    end
    
    add_index "apns_apps", ["bundle_identifier"], :name => "index_apns_apps_on_bundle_identifier"
        
    
    create_table "apns_devices", :force => true do |t|
      t.integer  "app_id"
      t.string   "token"
      t.string   "language"
      t.string   "locale"
      t.datetime "last_registered_at"
      t.datetime "created_at",         :null => false
      t.datetime "updated_at",         :null => false
    end

    add_index "apns_devices", ["token"], :name => "index_apns_devices_on_token"

    create_table "apns_notifications", :force => true do |t|
      t.integer  "device_id"
      t.string   "sound"
      t.string   "body"
      t.integer  "badge"
      t.string   "launch_image"
      t.string   "action_localized_key"
      t.string   "body_localized_key"
      t.text     "body_localized_arguments"
      t.text     "custom_payloads"
      t.datetime "send_at"
      t.datetime "sent_at"
      t.datetime "created_at",        :null => false
      t.datetime "updated_at",        :null => false
    end

    add_index "apns_notifications", ["device_id"], :name => "index_apns_notifications_on_device_id"

  end

  def self.down
    drop_table "apns_apps"
    drop_table "apns_devices"
    drop_table "apns_notifications"
  end
end