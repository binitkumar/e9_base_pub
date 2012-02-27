require 'rails/generators'
require 'rails/generators/migration'

module E9Base
  module Generators
    class MigrationGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      def self.source_root
        File.join(File.dirname(__FILE__), 'templates')
      end
       
      def self.next_migration_number(dirname) #:nodoc:
        if ActiveRecord::Base.timestamped_migrations
          Time.now.utc.strftime("%Y%m%d%H%M%S")
        else
          "%.3d" % (current_migration_number(dirname) + 1)
        end
      end

      # Every method that is declared below will be automatically executed when the generator is run
      #
      def create_migration_file
        migration_template 'e9_baseline.erb', 'db/migrate/e9_baseline.rb'
      end

      private
      
      def schema
        @_schema ||= begin
          ''.tap do |schema|
            File.readlines(File.join(File.dirname(__FILE__), '../../../db/schema.rb')).each do |line|
              unless line =~ /^(#|ActiveRecord|end)/
                schema << "  #{line}"
              end
            end
          end
        end
      end

    end
  end
end
