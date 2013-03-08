module APNS
  class Railtie < Rails::Railtie

    rake_tasks do
      load "tasks/apns.rake"
    end
    
    generators do
      require "generators/apns_on_rails/migrations_generator.rb"
    end
    
  end
end

require 'apns_on_rails'
