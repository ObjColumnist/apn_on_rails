# Represents the message you wish to send. 
# An APN::Notification belongs to an APN::Device.
# 
# Example:
#   apn = APN::Notification.new
#   apn.badge = 5
#   apn.sound = 'my_sound.aiff'
#   apn.body = 'Hello!'
#   apn.device = APN::Device.find(1)
#   apn.save
# 
# To deliver call the following method:
#   APN::Notification.send_notifications
# 
# As each APN::Notification is sent the <tt>sent_at</tt> column will be timestamped,
# so as to not be sent again.
class APN::Notification < APN::Base
  include ::ActionView::Helpers::TextHelper
  extend ::ActionView::Helpers::TextHelper
  serialize :custom_payloads
  serialize :localized_key_arguments
  
  belongs_to :device, :class_name => 'APN::Device'
  has_one    :app,    :class_name => 'APN::App', :through => :device
  
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
  
  # Creates a Hash that will be the payload of an APN.
  # 
  # Example:
  #   apn = APN::Notification.new
  #   apn.badge = 5
  #   apn.sound = 'my_sound.aiff'
  #   apn.body = 'Hello!'
  #   apn.apple_hash # => {"aps" => {"badge" => 5, "sound" => "my_sound.aiff", "alert":{"body":"Hello!"}}}
  #
  # Example 2: 
  #   apn = APN::Notification.new
  #   apn.badge = 0
  #   apn.sound = true
  #   apn.custom_payloads = {"typ" => 1}
  #   apn.apple_hash # => {"aps" => {"badge" => 0, "sound" => "1.aiff"}, "typ" => "1"}
  def apple_hash
    result = {}
    result['aps'] = {}
    result['aps']['alert'] = {}
    result['aps']['alert']['body'] = self.body if self.body
    result['aps']['alert']['loc-key'] = self.localized_key if self.localized_key
    result['aps']['alert']['loc-args'] = self.localized_key_arguments if self.localized_key_arguments
    result['aps']['alert']['action-loc-key'] = self.action_localized_key if self.action_localized_key
    result['aps']['alert']['launch-image'] = self.launch_image if self.launch_image
    result['aps']['badge'] = self.badge.to_i if self.badge
    result['aps']['sound'] = self.sound if self.sound

    if self.custom_payloads
      self.custom_payloads.each do |key,value|
        result["#{key}"] = value
      end
    end
    result
  end
  
  # Creates the JSON string required for an APN message.
  # 
  # Example:
  #   apn = APN::Notification.new
  #   apn.badge = 5
  #   apn.sound = 'my_sound.aiff'
  #   apn.body = 'Hello!'
  #   apn.to_apple_json # => '{"aps":{"badge":5,"sound":"my_sound.aiff","alert":{"body":"Hello!"}}}'
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
  
end # APN::Notification
