class APN::App < APN::Base
  
  has_many :devices, :class_name => 'APN::Device', :dependent => :destroy
  has_many :notifications, :through => :devices, :dependent => :destroy
  has_many :unsent_notifications, :through => :devices
  
  validates_presence_of :cert
  
  # Opens a connection to the Apple APN server and attempts to batch deliver
  # an Array of group notifications.

  def send_notifications
    if self.cert.nil?
      raise APN::Errors::MissingCertificateError.new
      return
    end
    APN::App.send_notifications_for_cert(self.cert, self.id)
  end
  
  def self.send_notifications
    apps = APN::App.all
     
    apps.each do |app|
      app.send_notifications
    end
  end
  
  def self.send_notifications_for_cert(the_cert, app_id)
    begin
      APN::Connection.open_for_delivery({:cert => the_cert}) do |conn, sock|
        
        unset = APN::Notification.joins(:device).where(:sent_at => nil, :apn_devices => { :app_id => app_id }).order(:device_id, :created_at).readonly(false)
        
        unset.each do |noty|
          Rails.logger.debug "Sending notification ##{noty.id}"
          begin
            conn.write(noty.message_for_sending)
          rescue => e
            Rails.logger.error "Cannot send notification ##{noty.id}: " + e.message
            if e.message == "Broken pipe"
              sleep 1
              retry
            end
          end
          
          noty.sent_at = Time.now
          noty.save
        end
        
      end
    rescue Exception => e
      log_connection_exception(e)
    end
  end
           
  
  # Retrieves a list of APN::Device instances from Apple using
  # the <tt>devices</tt> method. It then checks to see if the
  # <tt>last_registered_at</tt> date of each APN::Device is
  # before the date that Apple says the device is no longer
  # accepting notifications then the device is deleted. Otherwise
  # it is assumed that the application has been re-installed
  # and is available for notifications.
  # 
  # This can be run from the following Rake task:
  #   $ rake apn:feedback:process
  def process_devices
    if self.cert.nil?
      raise APN::Errors::MissingCertificateError.new
      return
    end
    APN::App.process_devices_for_cert(self.cert)
  end # process_devices
  
  def self.process_devices
    apps = APN::App.all
    
    apps.each do |app|
      app.process_devices
    end
  end
  
  def self.process_devices_for_cert(the_cert)
    puts "in APN::App.process_devices_for_cert"
    APN::Feedback.devices(the_cert).each do |device|
      if device.last_registered_at < device.feedback_at
        puts "device #{device.id} -> #{device.last_registered_at} < #{device.feedback_at}"
        device.destroy
      else 
        puts "device #{device.id} -> #{device.last_registered_at} not < #{device.feedback_at}"
      end
    end 
  end
  
  def self.log_connection_exception(ex)
    Rails.logger.error "apn_on_rails - Connection error: " + ex.message
  end
  
  protected
  
  def log_connection_exception(ex)
    Rails.logger.error "apn_on_rails - Connection error: " + ex.message
  end
    
end
