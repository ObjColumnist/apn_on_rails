namespace :apns do
  
  namespace :notifications do
    
    desc "Deliver all unsent APNS notifications."
    task :deliver => [:environment] do
      APNS::App.send_notifications
    end

  end # notifications
  
  namespace :feedback do
    
    desc "Process all devices that have feedback from APNS."
    task :process => [:environment] do
      APNS::App.process_devices
    end
    
  end
  
end # apns
