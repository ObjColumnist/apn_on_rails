require 'socket'
require 'openssl'
require 'rails'

require 'apn_on_rails/railtie.rb' if defined? Rails
require 'apn_on_rails/version.rb'
require 'apn_on_rails/models/base.rb'
require 'apn_on_rails/models/app.rb'
require 'apn_on_rails/models/device.rb'
require 'apn_on_rails/models/notification.rb'
require 'apn_on_rails/connection.rb'
require 'apn_on_rails/feedback.rb'


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