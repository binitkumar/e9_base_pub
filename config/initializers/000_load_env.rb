env = File.join Rails.root, ".env"

if File.exists?(env)
  YAML.load_file(env).each do |key, value|
    ENV[key] = value
  end
end
