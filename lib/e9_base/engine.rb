require 'rails'

require 'awesome_nested_set'
require 'carrierwave'
require 'devise'
require 'delayed_job'
require 'devise_revokable'
require 'haml'
require 'sass'
require 'inherited_resources'
require 'will_paginate'
require 'jammit'

module E9Base
  ASSETS_DIR = 'static'

  def E9Base.static_paths
    @_static_paths ||= begin
      paths = %w(
        /404.html
        /422.html
        /500.html
        /crossdomain.xml
        /favicon.ico
        /fonts
        /images
        /javascripts
        /robots.txt
        /stylesheets
        /swf
      )

      # In production we serve assets statically (not Jammit)...
      if Rails.env.production?
        paths << '/assets'

      # ...while in development we still need to serve from /static, but not cache
      else
        paths.map {|url| "#{url}*" }
      end
    end
  end

  class Engine < Rails::Engine
    config.e9_base = E9Base
    config.autoload_paths += %w(lib lib/validators).map {|dir| File.join(config.root, dir) }

    config.active_record.observers ||= []
    config.active_record.observers |= [ 
      :blog_page_observer,
      :forum_page_observer,
      :event_transaction_observer,
      :event_registration_observer,
      :user_observer,
      :content_view_observer, 
      :comment_observer, 
      :favoritables_observer,
      :faq_and_question_observer
    ]

    initializer 'e9_base.include_controller_module' do
      ActiveSupport.on_load(:action_controller) do
        include BaseController
      end
    end

    initializer 'e9_base.include_all_helpers', :before => 'action_controller.set_configs' do |app|
      # ensures our helpers path is included before action_controller is loaded and does its includes
      app.config.paths.app.helpers.concat config.paths.app.helpers.paths

      # NOTE this is essential for the static_cache setup below
      app.config.action_controller.assets_dir = E9Base::ASSETS_DIR
    end
    
    initializer 'e9_base.add_final_catchall_route', :after => :build_middleware_stack do |app|
      app.routes_reloader.paths << File.join(File.dirname(__FILE__), "routes.rb")
    end
  end
end
