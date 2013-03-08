#Currently Migrating to a new Gem don't use ... Yet :)

# APNS on Rails

APNS on Rails is a lightweight Ruby on Rails gem that adds support for the Apple Push Notification Service to your Rails application.  

It supports:
 
* Multiple apps managed from a single Rails application
* Alerts, badges, sounds and custom payloads in notifications
* Batch sending of notifications


# Installation and Setup

### Converting Your Certificate

Once you have the certificate from Apple for your application, export your key
and the apple certificate as p12 files. Here is a quick walkthrough on how to do this:

1. Click the disclosure arrow next to your certificate in Keychain Access and select the certificate and the key. 
2. Right click and choose `Export 2 items...`. 
3. Choose the p12 format from the drop down and name it `cert.p12`. 

Now covert the p12 file to a pem file:

	$ openssl pkcs12 -in cert.p12 -out apple_push_notification_production.pem -nodes -clcerts

The contents of the certificate files will be stored in the app model for the app you want to send notifications to.

### Bundler

	gem 'apns_on_rails', :git => 'https://github.com/ObjColumnist/apns_on_rails.git'

### Setup and Configuration

To create the tables you need for APNS on Rails, run the following task:

	$ rails generate apns_on_rails:migrations
	
This will generate the database migration files which apns_on_rails needs to work, you will then need to run the following task to migrate your database:

	$ rake db:migrate

The following has now been added to your database:

	create_table "apns_apps", :force => true do |t|
	   t.string   "bundle_identifier"
	   t.text     "cert"
	   t.datetime "created_at", :null => false
	   t.datetime "updated_at", :null => false
	 end

	 create_table "apns_devices", :force => true do |t|
	   t.string   "token",              :null => false
	   t.string   "language"
	   t.datetime "created_at",         :null => false
	   t.datetime "updated_at",         :null => false
	   t.integer  "app_id"
	   t.datetime "last_registered_at"
	 end

	 add_index "apns_devices", ["token"], :name => "index_apns_devices_on_token"

	 create_table "apns_notifications", :force => true do |t|
	   t.integer  "device_id",               :null => false
	   t.string   "sound"
	   t.string   "body"
	   t.integer  "badge"
	   t.string   "launch_image"
	   t.string   "action_localization_key"
	   t.string   "body_localization_key"
	   t.text     "body_localization_key_arguments"
	   t.text     "custom_payloads"
	   t.datetime "sent_at"
	   t.datetime "created_at",              :null => false
	   t.datetime "updated_at",              :null => false
	 end

	 add_index "apns_notifications", ["device_id"], :name => "index_apns_notifications_on_device_id"

##Example:

	$ rails console
	>> app = APNS::App.create(:apns_dev_cert => "PASTE YOUR DEV CERT HERE", :apns_prod_cert => "PASTE YOUR PROD CERT HERE")
	>> device = APNS::Device.create(:token => "XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX",:app_id => app.id)
	>> notification = APNS::Notification.new
	>> notification.device = device
	>> notification.badge = 5
	>> notification.sound = 'sound.wav'
	>> notification.body = 'foobar'
	>> notification.custom_payloads = {:link => "http://www.example.com"}
	>> notification.save
  
To prevent errors when copy and pasting your dev certs you can do it with Ruby

	>> app = APNS::App.create(:apns_dev_cert => Rails.root.join('config','certs','apns_development.pem').read,:apns_prod_cert => Rails.root.join('config', 'certs','apns_production.pem').read)  

You can use the following Rake task to deliver your individual notifications:

	$ rake apns:notifications:deliver

The Rake task will find any unsent notifications in the database. If there aren't any notifications it will simply do nothing. If there are notifications waiting to be delivered it will open a single connection to Apple and push all the notifications through that one connection. Apple does not like people opening/closing connections constantly, so it's pretty important that you are careful about batching up your notifications so Apple doesn't shut you down.


# Acknowledgements

This gem started off as a fork of apn_on_rails, but as there were numerous changes I wanted to make I thought it would be cleaner to start a new gem. Needless to say I couldn't have created this gem without the work of others, so the original acknowledgements of apn_on_rails are below.

From Mark Bates: 

This gem is a re-write of a plugin that was written by Fabien Penso and Sam Soffes.
Their plugin was a great start, but it just didn't quite reach the level I hoped it would.
I've re-written, as a gem, added a ton of tests, and I would like to think that I made it
a little nicer and easier to use.

From Rebecca Nesson (PRX.org): 

This gem extends the original version that Mark Bates adapted.  His gem did the hard
work of setting up and handling all communication with the Apple push notification servers.

# License

Released under the MIT license.
