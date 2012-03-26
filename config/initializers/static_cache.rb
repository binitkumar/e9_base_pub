require 'rack/contrib'

Rails.application.config.middleware.use Rack::StaticCache, {
  :urls       => E9Base.static_paths,
  :root       => E9Base::ASSETS_DIR,
  :versioning => false
}
