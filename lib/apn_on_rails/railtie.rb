module APN
  class Railtie < Rails::Railtie

    rake_tasks do
      load "apn_on_rails_tasks.rb"
    end
    
  end
end

require 'apn_on_rails'
