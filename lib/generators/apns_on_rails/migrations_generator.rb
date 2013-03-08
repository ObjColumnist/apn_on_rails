require 'rails/generators/active_record'

module ApnsOnRails
  module Generators
    class MigrationsGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      extend ActiveRecord::Generators::Migration
      
      # Set the current directory as base for the inherited generators.
      def self.base_root
        File.dirname(__FILE__)
      end
      
      source_root File.expand_path('../templates/migrations', __FILE__)
  
      def create_migrations

        templates = {
          'create_apns_on_rails.rb' => 'db/migrate/create_apns_on_rails.rb',
        }

        templates.each_pair do |name, path|
          begin
            migration_template(name, path)
          rescue => err
            puts "WARNING: #{err.message}"
          end
        end
      end
    end
  end
end
