#Currently Migrating to a new Gem don't use ... Yet :)

# APNS on Rails

APNS on Rails is a lightweight gem that adds support for the Apple Push Notification Service to your Rails application.  

It supports:
 
* Multiple apps managed from a single Rails application
* Localized alerts, action buttons, badges, sounds, launch images and custom payloads in notifications
* Scheduling of Notifications
* Supports both iOS and OS X apps
* Batch sending of notifications


# Installation and Setup

### Converting Your SSL Certificate

Once you have downloaded the SSL Certificate and added it to the Keychain Access app, you will need to export your Private Key and the SSL Certificate as a p12 file. Here is a quick walkthrough on how to do this:

1. Click the disclosure arrow next to your SSL Certificate in Keychain Access to reveal the Private Key
2. Select both the SSL Certificate and the Private Key. 
3. Right click and choose `Export 2 items...`. 
4. Choose the p12 format from the drop down and name it something like `cert.p12`. 

Now covert the p12 file to a pem file:

	$ openssl pkcs12 -in cert.p12 -out certificate.pem -nodes -clcerts

The contents of the pem certificate file will be stored in the app model for the app you want to send notifications to.

### Installing the Gem

Simply add the following line to your gem file

	gem 'apns_on_rails', :git => 'https://github.com/ObjColumnist/apn_on_rails.git'
	
Then run bundle to install the gem

	$ bundle

### Setup and Configuration

To create the tables needed for APNS on Rails, first run the following task to generate the database migration files:

	$ rails generate apns_on_rails:migrations
	
Then run these migrations on your database:

	$ rake db:migrate

The following has now been added to your database:

```ruby
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
```
###Environment

APNS on Rails uses `Rails.env` to decide whether to connect to Apple's Production or Sandbox servers. If `Rails.env.production?` is `true` APNS on Rails connects to Apple's Production servers, else it connects to their Sandbox servers.

You can override this before calling any _apns_on_rails_ code (for example in _environment.rb_) by setting the APNS Environment to `production` or `sandbox`
```ruby
APNS.configuration.merge!({
	:environment => 'production'
})
```

You can also override the connection and feedback connections settings, but these are automatically configured for Production and Sandbox environments
```ruby
APNS::Connection.configuration.merge!({
	:passphrase => '',
	:port => 2195,
	:passphrase => 'gateway.push.apple.com'
})

APNS::Connection.feedback_configuration.merge!({
	:passphrase => '',
	:port => 2196,
	:passphrase => 'feedback.gateway.push.apple.com'
})
```

##Sending a Push Notification

To send our first push notification we will use the _rails console_, you can start this by typing the following into terminal:
```ruby
$ rails console
```

Each notification has a relationship with device, which in turn has a relationship with an app.

The first thing we need to do is to create an app. You will need to specify a `platform` which can be either `ios` or `osx`, the `environment` (this defaults to the current APNS Environment), `bundle_identifier` and the `certificate` which is the contents of the *p12* that we created earlier:

```ruby
>> app = APNS::App.new
>> app.platform = 'ios'
>> app.environement = 'production'
>> app.bundle_identifier = 'com.example.app'
>> app.certificate = File.read('/path/to/certificate.pem')
>> app.save
```

You will then need to create a device using the device token, which is returned by Apple after you have successfully registered for push notifications:

```ruby
>> device = APNS::Device.new
>> device.token = "XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX"
>> device.app = app
>> device.save
```

You can then create a notification and associate it with a device, all of the other attributes are optional:

```ruby
>> notification = APNS::Notification.new
>> notification.device = device
>> notification.badge = 5
>> notification.sound = 'sound.wav'
>> notification.body = 'foobar'
>> notification.save
```

You can localize the body of notification using `body_localized_key` and optionally supply an array of arguments using `body_localized_arguments`

For example if you have the following in your strings file:
```
"FRIEND_HIGHSCORE_APNS_FORMAT" = "%@ just got a highscore of %@";
```
	
You can configure the notification like so:

```ruby
notification.body_localized_key = 'FRIEND_HIGHSCORE_APNS_FORMAT'
notification.body_localized_arguments = ['Spencer',100]
```

You can set a custom launch image (instead of _Default.png_) by using `launch_image`:
```ruby
notification.launch_image = 'NotificationLaunchImage.png'
```

You can supply custom payloads using `custom_playloads`, this takes a Hash which is merged with the Push Notification Hash before sending:

```ruby
notification.custom_payloads = {:link => "http://www.example.com"}
```

To Schedule a notification for the future simple set `send_at`:

```ruby
notification.send_at = Time.new(2020,1,1)
```

You can use the following Rake task to deliver your individual notifications:

```ruby
$ rake apns:notifications:deliver
```

The Rake task will find any unsent notifications in the database who's `send_at` date is in the past. If there aren't any notifications it will simply do nothing. If there are notifications waiting to be delivered it will open a single connection to Apple and push all the notifications through that one connection. Apple does not like people opening/closing connections constantly, so it's pretty important that you are careful about batching up your notifications so Apple doesn't shut you down.


# Acknowledgements

This gem started off as a fork of apn_on_rails, but as there were numerous changes I wanted to make I thought it would be cleaner to start a new gem. Needless to say I couldn't have created this gem without the work of others, so the original acknowledgements of apn_on_rails are below.

From Mark Bates: 

This gem is a re-write of a plugin that was written by Fabien Penso and Sam Soffes.
Their plugin was a great start, but it just didn't quite reach the level I hoped it would.
I've re-written, as a gem, added a ton of tests, and I would like to think that I made it a little nicer and easier to use.

From Rebecca Nesson (PRX.org): 

This gem extends the original version that Mark Bates adapted. His gem did the hard work of setting up and handling all communication with the Apple push notification servers.

# License

Released under the MIT license.
