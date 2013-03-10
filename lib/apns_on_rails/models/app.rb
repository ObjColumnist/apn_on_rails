class APNS::App < APNS::Base
  
  has_many :devices, :class_name => 'APNS::Device', :dependent => :destroy
  has_many :notifications, :through => :devices, :dependent => :destroy
  has_many :unsent_notifications, :through => :devices
  
  validates_presence_of :bundle_identifier
  validates_presence_of :platform
  validates_inclusion_of :platform, :in => [:ios,:osx]
  validates_presence_of :environment
	validates_inclusion_of :environment, :in => [:production,:sandbox]
	validates_presence_of :certificate
	
	after_initialize :set_platform
	after_initialize :set_environment
  
  # Opens a connection to the Apple APNS server and attempts to batch deliver
  # an Array of group notifications.
  
  def self.send_notifications
    apps = APNS::App.where(:environment => APNS.configuration[:environment])
     
    apps.each do |app|
      app.send_notifications
    end
  end

  def send_notifications
    if self.certificate.nil?
      raise APNS::Errors::MissingCertificateError.new
      return
    end
    
    if self.environment.to_s != APNS.configuration[:environment].to_s
       raise APNS::Errors::IncorrectEnvironmentError.new
       return
     end
    
    begin
      APNS::Connection.open_for_delivery({:certificate => self.certificate}) do |conn, sock|
        
        unsent = APNS::Notification.joins(:device).where(:sent_at => nil, :apns_devices => { :app_id => id }).where("send_at <= ?", Time.now).order(:device_id, :created_at).readonly(false)
        unsent.each do |notification|
          Rails.logger.debug "Sending notification ##{notification.id}"
          begin
            conn.write(notification.message_for_sending)
          rescue => e
            Rails.logger.error "Cannot send notification ##{notification.id}: " + e.message
            if e.message == "Broken pipe"
              sleep 1
              retry
            end
          end
          
          notification.sent_at = Time.now
          notification.save
        end
        
      end
    rescue Exception => e
      log_connection_exception(e)
    end
    
  end        
  
  # Retrieves a list of APNS::Device instances from Apple using
  # the <tt>devices</tt> method. It then checks to see if the
  # <tt>last_registered_at</tt> date of each APNS::Device is
  # before the date that Apple says the device is no longer
  # accepting notifications then the device is deleted. Otherwise
  # it is assumed that the application has been re-installed
  # and is available for notifications.
  # 
  # This can be run from the following Rake task:
  #   $ rake apns:feedback:process
  def process_devices
    if self.certificate.nil?
      raise APNS::Errors::MissingCertificateError.new
      return
    end
    APNS::App.process_devices_for_certificate(self.certificate)
  end # process_devices
  
  def self.process_devices
    apps = APNS::App.all
    
    apps.each do |app|
      app.process_devices
    end
  end
  
  def self.process_devices_for_certificate(the_certificate)
    APNS::Feedback.devices(the_certificate).each do |device|
      if device.last_registered_at < device.feedback_at
        puts "device #{device.id} -> #{device.last_registered_at} < #{device.feedback_at}"
        device.destroy
      else 
        puts "device #{device.id} -> #{device.last_registered_at} not < #{device.feedback_at}"
      end
    end 
  end
  
  def self.log_connection_exception(ex)
    Rails.logger.error "apns_on_rails - Connection error: " + ex.message
  end
  
  protected
  
  def log_connection_exception(ex)
    Rails.logger.error "apns_on_rails - Connection error: " + ex.message
  end
  
  def set_platform
    self.platform = :ios
  end
  
  def set_environment
	  self.environment = APNS.configuration[:environment] if self.environment.nil?
	end
    
end
