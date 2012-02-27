require 'rails/generators'
require 'rails/generators/migration'

module E9Base
  module Generators
    class InstallGenerator < Rails::Generators::Base

      def self.source_root
        File.join(File.dirname(__FILE__), 'templates')
      end

      def remove_default_overrides
        remove_file 'app/helpers/application_helper.rb'
        remove_file 'app/views/layouts/application.html.haml'
        remove_file 'app/views/layouts/application.html.erb'
        # NOTE really this should remove all public
        remove_file 'public/index.html'
      end

      #def copy_public
        #directory '../../../../public/images', 'public/images'
        #directory '../../../../public/swf', 'public/swf'
        #copy_file '../../../../public/500.html', 'public/500.html'
        #copy_file '../../../../public/robots.txt', 'public/robots.txt'
        #copy_file '../../../../public/crossdomain.xml', 'public/crossdomain.xml'
      #end

      def copy_app_files
        copy_file '../../../../app/controllers/application_controller.rb', 'app/controllers/application_controller.rb'
      end

      def copy_stylesheets
        directory '../../../../app/stylesheets', 'app/stylesheets'
      end

      def copy_gitignore
        copy_file '../../../../.gitignore', '.gitignore'
      end

      #def copy_config_files
        #directory '../../../../site/config', 'config'
      #end

      def copy_seed_files
        copy_file '../../../../db/seeds.rb', 'db/seeds.rb'
        directory '../../../../db/seeds', 'db/seeds'
      end
    end
  end
end
