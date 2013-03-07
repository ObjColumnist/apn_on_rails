class CreateApnApps < ActiveRecord::Migration # :nodoc:
  def self.up
    create_table :apn_apps do |t|
      t.string :name
      t.string :bundle_identifier
      t.text :cert
      t.timestamps
    end

    add_column :apn_devices, :app_id, :integer
    
  end

  def self.down
    drop_table :apn_apps
    remove_column :apn_devices, :app_id
  end
end
