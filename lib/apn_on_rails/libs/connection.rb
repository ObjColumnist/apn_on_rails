module APN
  module Connection
    
    class << self
      
      def configuration
        if @configuration.nil?
          @configuration = {}
          @configuration[:passphrase] = ''
          @configuration[:port] = 2195
                
          if APN.configuration[:environment] == :production
            @configuration[:host] = 'gateway.push.apple.com'
          else
            @configuration[:host] = 'gateway.sandbox.push.apple.com'
          end
        end
        
        @configuration
      end
      
      def feedback_configuration
        if @feedback_configuration.nil?
          @feedback_configuration = {}
          @feedback_configuration[:passphrase] = ''
          @feedback_configuration[:port] = 2196
  
          if Rails.env == :production
            @feedback_configuration[:host] = 'feedback.push.apple.com'
          else
            @feedback_configuration[:host] = 'feedback.sandbox.push.apple.com'
          end
        end
        
        @feedback_configuration
      end
    
      # Yields up an SSL socket to write notifications to.
      # The connections are close automatically.
      # 
      #  Example:
      #   APN::Configuration.open_for_delivery do |conn|
      #     conn.write('my cool notification')
      #   end
      def open_for_delivery(options = {}, &block)
        options = {:cert => self.configuration[:cert],
                   :passphrase => self.configuration[:passphrase],
                   :host => self.configuration[:host],
                   :port => self.configuration[:port]}.merge(options)
        open(options, &block)
      end
      
      # Yields up an SSL socket to receive feedback from.
      # The connections are close automatically.
      def open_for_feedback(options = {}, &block)
        options = {:cert => self.feedback_configuration[:cert],
                   :passphrase => self.feedback_configuration[:passphrase],
                   :host => self.feedback_configuration[:host],
                   :port => self.feedback_configuration[:port]}.merge(options)
        open(options, &block)
      end
      
      private
      def open(options = {}, &block) # :nodoc:
        cert = options[:cert]
        ctx = OpenSSL::SSL::SSLContext.new
        ctx.key = OpenSSL::PKey::RSA.new(cert, options[:passphrase])
        ctx.cert = OpenSSL::X509::Certificate.new(cert)
  
        sock = TCPSocket.new(options[:host], options[:port])
        ssl = OpenSSL::SSL::SSLSocket.new(sock, ctx)
        ssl.sync = true
        ssl.connect
  
        yield ssl, sock if block_given?
  
        ssl.close
        sock.close
      end
      
    end
    
  end # Connection
end # APN