E9::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  config.cache_classes                     = true

  config.action_view.debug_rjs             = true
  config.consider_all_requests_local       = true

  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new
  config.cache_store = :memory_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = true

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  config.action_mailer.raise_delivery_errors = true

  ## Devise authentication link
  config.action_mailer.default_url_options = { :host => 'localhost' }

  ## Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  #config.middleware.use "Rack::Bug", :secret_key => "someverylongandhardtoguesspreferablyrandomstringasdfasdfasdfasdfasdfasdf"
end
