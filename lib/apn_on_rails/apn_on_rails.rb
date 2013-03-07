require 'socket'
require 'openssl'
require 'rails'

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

base = File.join(File.dirname(__FILE__), 'app', 'models', 'apn', 'base.rb')
require base

Dir.glob(File.join(File.dirname(__FILE__), 'app', 'models', 'apn', '*.rb')).sort.each do |f|
  require f
end

%w{ models controllers helpers }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  # puts "Adding #{path}"
  begin
    if ActiveSupport::Dependencies.respond_to? :autoload_paths
      ActiveSupport::Dependencies.autoload_paths << path
      ActiveSupport::Dependencies.autoload_once_paths.delete(path)
    else
      ActiveSupport::Dependencies.load_paths << path
      ActiveSupport::Dependencies.load_once_paths.delete(path)
    end
  rescue NameError
    Dependencies.load_paths << path
    Dependencies.load_once_paths.delete(path)
  end
end
