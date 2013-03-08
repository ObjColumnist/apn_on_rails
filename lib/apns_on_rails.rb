require 'socket'
require 'openssl'
require 'rails'

require 'apns_on_rails/railtie.rb' if defined? Rails
require 'apns_on_rails/version.rb'
require 'apns_on_rails/models/base.rb'
require 'apns_on_rails/models/app.rb'
require 'apns_on_rails/models/device.rb'
require 'apns_on_rails/models/notification.rb'
require 'apns_on_rails/connection.rb'
require 'apns_on_rails/feedback.rb'


module APNS # :nodoc:

  def self.configuration
    if @configuration.nil?
      @configuration = {}
            
      if Rails.env.production?
        @configuration[:environment] = :production
      else
        @configuration[:environment] = :development
      end
    end
    
    @configuration
  end
  
  module Errors # :nodoc:

    # Raised when a notification message to Apple is longer than 256 bytes.
    class ExceededMessageSizeError < StandardError

      def initialize(message) # :nodoc:
        super("The maximum size allowed for a notification payload is 256 bytes: '#{message}'")
      end

    end

    class MissingCertificateError < StandardError
      def initialize
        super("This app has no certificate")
      end
    end

  end # Errors

end # APNS