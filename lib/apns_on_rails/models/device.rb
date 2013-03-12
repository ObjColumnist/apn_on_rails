# Represents an iPhone (or other APNS enabled device).
# An APNS::Device can have many APNS::Notification.
# 
# In order for the APNS::Feedback system to work properly you *MUST*
# touch the <tt>last_registered_at</tt> column everytime someone opens
# your application. If you do not, then it is possible, and probably likely,
# that their device will be removed and will no longer receive notifications.
# 
# Example:
#   Device.create(:token => '5gxadhy6 6zmtxfl6 5zpbcxmw ez3w7ksf qscpr55t trknkzap 7yyt45sc g6jrw7qz')
class APNS::Device < APNS::Base
  
  belongs_to :app, :class_name => 'APNS::App'
  has_many :notifications, :class_name => 'APNS::Notification', :dependent => :destroy
  has_many :unsent_notifications, :class_name => 'APNS::Notification', :conditions => 'sent_at is null'
  
  validates_presence_of :token
  validates_uniqueness_of :token, :scope => :app_id
  validates_format_of :token, :with => /^[a-f0-9]{8}\s[a-f0-9]{8}\s[a-f0-9]{8}\s[a-f0-9]{8}\s[a-f0-9]{8}\s[a-f0-9]{8}\s[a-f0-9]{8}\s[a-f0-9]{8}$/
  
  before_create :set_last_registered_at
  
  # The <tt>feedback_at</tt> accessor is set when the 
  # device is marked as potentially disconnected from your
  # application by Apple.
  attr_accessor :feedback_at
  
  # Stores the token (Apple's device ID) of the iPhone (device).
  # 
  # If the token comes in like this:
  #  '<5gxadhy6 6zmtxfl6 5zpbcxmw ez3w7ksf qscpr55t trknkzap 7yyt45sc g6jrw7qz>'
  # Then the '<' and '>' will be stripped off.
  def token=(token)
    res = token.scan(/\<(.+)\>/).first
    unless res.nil? || res.empty?
      token = res.first
    end
    write_attribute('token', token)
  end
  
  # Returns the hexadecimal representation of the device's token.
  def to_hexa
    [self.token.delete(' ')].pack('H*')
  end
  
  def set_last_registered_at
    self.last_registered_at = Time.now
  end
  
end
