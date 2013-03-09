#Currently Migrating to a new Gem don't use ... Yet :)

# APNS on Rails

APNS on Rails is a lightweight gem that adds support for the Apple Push Notification Service to your Rails application.  

It supports:
 
* Multiple apps managed from a single Rails application
* Alerts, badges, sounds and custom payloads in notifications
* Batch sending of notifications


# Installation and Setup

### Converting Your Certificate

Once you have the certificate from Apple for your application, export your key and the apple certificate as p12 files. Here is a quick walkthrough on how to do this:

1. Click the disclosure arrow next to your certificate in Keychain Access and select the certificate and the key. 
2. Right click and choose `Export 2 items...`. 
3. Choose the p12 format from the drop down and name it `cert.p12`. 

Now covert the p12 file to a pem file:

	$ openssl pkcs12 -in cert.p12 -out apple_push_notification_production.pem -nodes -clcerts

The contents of the certificate files will be stored in the app model for the app you want to send notifications to.

### Bundler

	gem 'apns_on_rails', :git => 'https://github.com/ObjColumnist/apns_on_rails.git'

### Setup and Configuration

To create the tables need for APNS on Rails, run the following task to generate the database migration files that apns_on_rails needs to work:

	$ rails generate apns_on_rails:migrations
	
You will then need to run these migrations your database:

	$ rake db:migrate

The following has now been added to your database:

	create_table "apns_apps", :force => true do |t|
	  t.string   "bundle_identifier"
	  t.text     "certificate"
	  t.text     "environment"
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

#Configuration

##Environment

APNS on Rails uses your `RAILS_ENV` or `RACK_ENV` to decide whether to connect to Apple's Production or Sandbox server. If `Rails.env.production?` is `true` APNS on Rails connects to Apple's Production server else it connects to their sandbox environment.

You can over ride this (for example in environment.rb) by setting the APNS Environment to `:production` or `:sandbox`

	APNS.configuration.merge!({
		:environment => :production
	})

You can also override the connection settings, but these are automatically configured for Production and Sandbox environments

	APNS::Connection.configuration.merge!({
		:passphrase => :'',
		:port => 2195,
		:passphrase => 'gateway.push.apple.com'
	})

	APNS::Connection.feedback_configuration.merge!({
		:passphrase => :'',
		:port => 2196,
		:passphrase => 'feedback.gateway.push.apple.com'
	})


##Example:

	$ rails console
	>>
	>> app = APNS::App.new
	>> app.certificate = File.read("/path/to/development.pem")
	>> app.bundle_identifier => "com.example.app"
	>> app.save
	>>
	>> device = APNS::Device.new
	>> device.token = "XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX"
	>> device.app = app
	>> device.save
	>>
	>> notification = APNS::Notification.new
	>> notification.device = device
	>> notification.badge = 5
	>> notification.sound = 'sound.wav'
	>> notification.body = 'foobar'
	>> notification.custom_payloads = {:link => "http://www.example.com"}
	>> notification.save

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
