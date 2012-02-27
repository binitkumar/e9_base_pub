class E9::Config
  class << self
    def instance(reload = false)
      # TODO add support for multiple site configurations
      @_settings = nil if reload
      
      # NOTE rescue for env load before database is populated
      @_settings ||= begin
        ::Settings.find_or_create_by_name("Default Configuration")
      rescue => e
        Rails.logger.error("E9::Config: Load Error: #{e}")
        {}
      end
    end

    def reload!
      instance(true)
    end

    def cache!
      begin
        instance.save!
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error("E9::Config: Settings Invalid: errors[#{instance.errors.inspect}]  -- #{e}")

        begin
          instance
        rescue
          instance(true)
        end
        false
      rescue
        # for env load before database is populated
      end
    end

    def [](key)
      instance[key]
    end
    alias_method :get, :[]

    def []=(key, val)
      instance[key] = val
      cache!
    end
    alias_method :set, :[]=
  end
end
