# Represents the message you wish to send. 
# An APNS::Notification belongs to an APNS::Device.
# 
# Example:
#   apns = APNS::Notification.new
#   apns.badge = 5
#   apns.sound = 'my_sound.aiff'
#   apns.body = 'Hello!'
#   apns.device = APNS::Device.find(1)
#   apns.save
# 
# To deliver call the following method:
#   APNS::Notification.send_notifications
# 
# As each APNS::Notification is sent the <tt>sent_at</tt> column will be timestamped,
# so as to not be sent again.
class APNS::Notification < APNS::Base
  include ::ActionView::Helpers::TextHelper
  extend ::ActionView::Helpers::TextHelper
  serialize :custom_payloads
  serialize :body_localized_arguments
  
  belongs_to :device, :class_name => 'APNS::Device'
  has_one    :app,    :class_name => 'APNS::App', :through => :device
  
  # Stores the text body message you want to send to the device.
  # 
  # If the message is over 150 characters long it will get truncated
  # to 150 characters with a <tt>...</tt>
  def body=(message)
    if !message.blank? && message.size > 150
      message = truncate(message, :length => 150)
    end
    write_attribute('body', message)
  end
  
  # Creates a Hash that will be the payload of an APNS.
  # 
  # Example:
  #   apns = APNS::Notification.new
  #   apns.badge = 5
  #   apns.sound = 'my_sound.aiff'
  #   apns.body = 'Hello!'
  #   apns.apple_hash # => {"aps" => {"badge" => 5, "sound" => "my_sound.aiff", "alert":{"body":"Hello!"}}}
  #
  # Example 2: 
  #   apns = APNS::Notification.new
  #   apns.badge = 0
  #   apns.sound = true
  #   apns.custom_payloads = {"typ" => 1}
  #   apns.apple_hash # => {"aps" => {"badge" => 0, "sound" => "1.aiff"}, "typ" => "1"}
  def apple_hash
    result = {}
    result['aps'] = {}
    result['aps']['alert'] = {}
    result['aps']['alert']['body'] = self.body if self.body
    result['aps']['alert']['loc-key'] = self.body_localized_key if self.body_localized_key
    result['aps']['alert']['loc-args'] = self.body_localized_arguments if self.body_localized_arguments
    result['aps']['alert']['action-loc-key'] = self.action_localized_key if self.action_localized_key
    result['aps']['alert']['launch-image'] = self.launch_image if self.launch_image
    result['aps']['badge'] = self.badge.to_i if self.badge
    result['aps']['sound'] = self.sound if self.sound

    if self.custom_payloads
      result.merge!(self.custom_payloads)
    end
    
    result
  end
  
  # Creates the JSON string required for an APNS message.
  # 
  # Example:
  #   apns = APNS::Notification.new
  #   apns.badge = 5
  #   apns.sound = 'my_sound.aiff'
  #   apns.body = 'Hello!'
  #   apns.to_apple_json # => '{"aps":{"badge":5,"sound":"my_sound.aiff","alert":{"body":"Hello!"}}}'
  def to_apple_json
    logger.debug self.apple_hash.to_json
    self.apple_hash.to_json
  end
  
  # Creates the binary message needed to send to Apple.
  def message_for_sending
    json = self.to_apple_json
    message = "\0\0 #{self.device.to_hexa}\0#{json.length.chr.force_encoding 'ascii-8bit'}#{json}"
    message
  end
  
end # APNS::Notification
