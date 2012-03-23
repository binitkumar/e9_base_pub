require 'rack/contrib'

Rails.application.config.tap do |config|
  # Cache static assets in a separate folder from public, and use Rack::StaticCache
  # to serve them.  This is mainly for Heroku.
  $assets_dir  = 'static'
  $static_urls = %w(
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
    $static_urls.push('/assets')

  # ...while in development we still need to serve from /static, but not cache
  else
    $static_urls.map! {|url| "#{url}*" }
  end

  # We change the assets_dir as well to ensure we're still getting a cache buster
  config.action_controller.assets_dir = File.join(Rails.root, $assets_dir)

  config.middleware.use(Rack::StaticCache, {
    :urls       => $static_urls,
    :root       => $assets_dir,
    :versioning => false
  })
end
