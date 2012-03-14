require 'dragonfly'
require 'rack/cache'

app = Dragonfly[:images]
app.configure_with(:imagemagick)
app.configure_with(:rails)
app.define_macro(ActiveRecord::Base, :image_accessor)

if Rails.env.production? || ENV['USE_S3']
  app.datastore = Dragonfly::DataStorage::S3DataStore.new

  app.datastore.configure do |c|
    c.bucket_name       = E9::AWS.config[:bucket_name]
    c.region            = E9::AWS.config[:region]
    c.access_key_id     = E9::AWS.config[:access_key_id]
    c.secret_access_key = E9::AWS.config[:secret_access_key]
    #c.storage_headers = {'some' => 'thing'}       # defaults to {'x-amz-acl' => 'public-read'}
    #c.url_scheme = 'https'                        # defaults to 'http'
  end
end

Rails.application.config.tap do |config|
  config.middleware.insert 0, 'Rack::Cache', {
    :verbose     => true,
    :metastore   => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/meta"),
    :entitystore => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/body")
  } unless Rails.env.production?

  config.middleware.insert_after 'Rack::Cache', 'Dragonfly::Middleware', :images
end
