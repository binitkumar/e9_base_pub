require 'rack'
require 'rack/contrib'

Rails.application.config.middleware.insert_after('Rack::Cache', Rack::StaticCache, {
  :urls       => E9Base.static_paths,
  :root       => E9Base::ASSETS_DIR,
  :versioning => false
})
