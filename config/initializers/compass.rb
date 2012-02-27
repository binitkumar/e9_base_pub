# fall back to the gem's auth rules if their config is not found locally
if defined?(Rails) && File.exists?(config = File.join(Rails.root, 'config', 'compass.rb'))
  require 'sass'
  require 'compass'
  require 'rgbapng'

  Compass::Frameworks.register("e9_base",
    :stylesheets_directory  => File.join(File.dirname(__FILE__), "../../app/stylesheets"),
    :templates_directory    => File.join(File.dirname(__FILE__), "../../app/templates")
  )

  Compass.add_project_configuration(config)
  Compass.configure_sass_plugin!

  Compass.handle_configuration_change!
end
