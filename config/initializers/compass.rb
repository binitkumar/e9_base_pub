# fall back to the gem's auth rules if their config is not found locally
if Rails.env.development? && File.exists?(config = File.join(Rails.root, 'config', 'compass.rb'))
  require 'compass'

  Compass.add_project_configuration(config)
  Compass.configure_sass_plugin!

  Compass.handle_configuration_change!
end
