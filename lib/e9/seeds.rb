module E9
  module Seeds
    FIXTURES = {}

    def fetch_fixture(klass_name, identifier)
      FIXTURES[klass_name][identifier.to_s.strip].tap do |retv|
        if retv.nil?
          puts "  Error: fetch_fixture - #{klass_name}:#{identifier} not found"
          exit 1
        end

        retv.reload
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

    def fixture_globs
      ['', Rails.env].map do |path| 
        File.join(Rails.root, '{,vendor/e9_base/}db/fixtures', path, "[0-9]*.*")
      end
    end

    def fixtures
      # sort based on basename, but also the presence of e9_base in the path, so the
      # result is e.g.
      #
      #     [
      #       'db/fixtures/0_foo.yml', 
      #       'vendor/e9_base/db/fixtures/0_foo.yml', 
      #       'db/fixtures/1_bar.yml'
      #       'vendor/e9_base/db/fixtures/3_baz.yml'
      #     ]
      #
      retv = Dir[*fixture_globs].sort_by do |path| 
        [File.basename(path), path.include?('e9_base') ? 1 : 0]
      end

      # the above ordering is then useful in that we'll select the first duplicate
      # in the result. The presence of 0_foo.yml locally overrides 0_foo.yml in e9_base,
      # and the latter is knocked out.  The end result is that all local seeds take
      # precedence and replace the e9_base default seeds.
      retv.inject([]) do |mem, path|
        mem << path if mem.empty? || File.basename(mem[-1]) != File.basename(path)
        mem
      end
    end

    def load!
      fixtures.each do |fixture|
        if fixture =~ /yml$/
          collection = /\/\d+_(\w+)\.yml/.match(fixture)[1]
          klass_name = collection.classify

          begin
            klass = klass_name.constantize
          rescue NameError
            puts "Skipping #{fixture} as no matching constant #{klass_name} found"
            next
          end

          # before hook
          if File.exists?(process_script = "#{File.dirname(fixture)}/before_#{collection}.rb")
            puts "  Loading before hook: #{process_script}"
            load process_script
          end

          puts "Loading #{fixture}"
          yaml = YAML.load(ERB.new(IO.read(fixture)).result)
          fixtures = Seeds.prepare_fixture(klass, yaml)
          puts "  #{fixtures.keys.length} #{klass_name} records loaded" if fixtures.present?

          # after hook
          if File.exists?(process_script = "#{File.dirname(fixture)}/after_#{collection}.rb")
            puts "  Loading after hook: #{process_script}"
            load process_script
          end

        elsif fixture =~ /rb$/
          puts "Loading #{fixture}"
          load fixture
        end
      end
    end

    extend self
  end
end
