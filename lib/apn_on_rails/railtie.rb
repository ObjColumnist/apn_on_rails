module APN
  class Railtie < Rails::Railtie

    rake_tasks do
      load "tasks/apn.rake"
    end
    
    generators do
      require "generators/apn_on_rails/migrations_generator.rb"
    end
    
  end
end

require 'apn_on_rails'
