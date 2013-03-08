require 'socket'
require 'openssl'
require 'rails'

require 'apn_on_rails/app/models/apn/base.rb'
require 'apn_on_rails/app/models/apn/app.rb'
require 'apn_on_rails/app/models/apn/device.rb'
require 'apn_on_rails/app/models/apn/notification.rb'


module APN # :nodoc:

  def configuration
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

end # APN