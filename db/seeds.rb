module E9Seeds
  FIXTURES = {}

  def fetch_fixture(klass_name, identifier)
    FIXTURES[klass_name][identifier.to_s.strip].tap do |retv|
      if retv.nil?
        puts "  Error: fetch_fixture - #{klass_name}:#{identifier} not found"
        exit 1
      end
    end
  rescue
    puts "  Error: fetch_fixture - #{klass_name} not yet loaded"
    exit 1
  end

  def fetch_fixtures(klass_name, *identifiers)
    identifiers.flatten.map do |identifier|
      fetch_fixture(klass_name, identifier)
    end
  end

  def store_fixture(klass, identifier, arguments, options = {})
    key = klass.name

    klass = options[:klass].presence || klass

    if options[:finder]
      finders       = options[:finder].to_s.split('_and_')
      finder_values = finders.map {|v| arguments[v] }
      finder_args   = Hash[finders.zip(finder_values)]

      fixture = klass.where(finder_args).first 
    end

    fixture ||= klass.new
    fixture.attributes = arguments.except('id')

    validate = case options[:validate]
               when false    then false
               when 'create' then fixture.new_record?
               when 'update' then fixture.persisted?
               else true
               end

    fixture.save! :validate => validate

    FIXTURES[key] ||= {}
    FIXTURES[key][identifier] = fixture
  end

  def prepare_fixture(klass, data)
    data && data.each do |data_key, data_value|
      next if data_key =~ /^_/

      args, options = {}, {}

      data_value.each do |key, value|
        case key
        when '_klass'
          options[:klass] = value.constantize rescue nil
        when '_validate'
          options[:validate] = value
        when '_finder'
          options[:finder] = value
        else
          args[key] = if refl = klass.reflect_on_association(key.to_sym)
            refl_name = if value =~ /(\w+) \((\w+)\)/
              value = $1
              $2
            else
              refl.class_name
            end

            if refl.collection?
              fetch_fixtures(refl_name, *value.split(','))
            else
              fetch_fixture(refl_name, value)
            end
          else
            value
          end
        end
      end

      store_fixture(klass, data_key, args, options)
    end

    FIXTURES[klass.name]
  end

  extend self
end

paths = ['', Rails.env].map do |path| 
  File.join File.dirname(__FILE__), 'fixtures', path, "[0-9]*.*"
end

Dir[*paths].sort_by {|p| File.basename(p) }.each do |fixture|
  if fixture =~ /yml$/
    collection = /\/\d+_(\w+)\.yml/.match(fixture)[1]
    klass_name = collection.classify

    begin
      klass = klass_name.constantize
    rescue NameError
      puts "Skipping #{File.basename(fixture)} as no matching constant #{klass_name} found"
      next
    end

    # before hook
    if File.exists?(process_script = "#{File.dirname(fixture)}/before_#{collection}.rb")
      puts "  Loading before hook: #{File.basename(process_script)}"
      load process_script
    end

    puts "Loading #{File.basename(fixture)}"
    yaml = YAML.load(ERB.new(IO.read(fixture)).result)
    fixtures = E9Seeds.prepare_fixture(klass, yaml)
    puts "  #{fixtures.keys.length} #{klass_name} records loaded"

    # after hook
    if File.exists?(process_script = "#{File.dirname(fixture)}/after_#{collection}.rb")
      puts "  Loading after hook: #{File.basename(process_script)}"
      load process_script
    end

  elsif fixture =~ /rb$/
    puts "Loading #{File.basename(fixture)}"
    load fixture
  end
end
