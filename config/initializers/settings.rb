Settings.reset_default_attribute_values!

Dir["#{Rails.root}/config/*settings.yml"].each do |file|
  Rails.logger.info("Loaded settings file: #{file}")
  Settings.add_default_config_file(file)
end
