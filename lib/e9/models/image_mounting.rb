module E9::Models

  module ImageMounting
    extend ActiveSupport::Concern

    included do
      class_attribute :image_mounting_options
    end

    delegate :mounted_as_name_for, :mounted_as_options_for, :to => 'self.class'

    def _init_image_mount(association, mount)
      options = mounted_as_options_for(association)

      mount.spec = case options[:spec]
      when Array
        mount.spec_width, mount.spec_height = options[:spec]
        nil
      when String
        s = eval options[:spec]
        s if s.kind_of?(E9::ImageSpecification)
      else
        mount.local_spec
      end

      if options[:fallback_url]
        mount.fallback_url = options[:fallback_url]
      end

      mount.mounted_as = mounted_as_name_for(association)
      mount.owner = self
    end

    def mounted_image_versions_for(association)
      options = mounted_as_options_for(association)
      (options[:versions] || []).map do |version|
        method = options[:prefix_version] ? "#{association}_#{version}" : version
        send(method) if respond_to?(method)
      end.compact
    end

    def mounted_image_parent_for(association)
      if options = mounted_as_options_for(association)
        method = options[:parent]
        send(method) if method && respond_to?(method)
      end
    end

    protected :_init_image_mount

    module ClassMethods
      def mounted_as_name_for(association) 
        '%s#%s' % [base_class.name.underscore, association]
      end

      def mounted_as_options_for(association)
        image_mounting_options[association.to_s]
      end

      def mounts_image(association='image', options={})
        unless methods(false).member?(:image_mounting_options)
          self.image_mounting_options = (self.image_mounting_options || {}).dup
        end

        if is_collection = options.delete(:collection)
          macro = 'has_many'
          yield_method = 'each'
        else
          macro = 'has_one'
          yield_method = 'tap'
        end

        init_method = "_init_#{association}_image_mount"
        yielder = "#{association}.#{yield_method}"

        eval_code = <<-RUBY
          #{macro} :#{association}, {
            :as         => :owner,
            :class_name => 'ImageMount',
            #{":before_add => :#{init_method}," if is_collection}
            #{":autosave => true," unless is_collection}
            :conditions => { :mounted_as => "#{mounted_as_name_for(association)}" }
          }

          accepts_nested_attributes_for :#{association}

          def #{init_method}(mount)
            _init_image_mount('#{association}', mount)
          end
          protected :#{init_method}
        RUBY

        unless is_collection
          eval_code << <<-RUBY
            alias :_build_#{association} :build_#{association}

            def build_#{association}(options={})
              _build_#{association}(options).tap do |mount|
                #{init_method}(mount)
              end
            end

            alias :_get_#{association} :#{association}

            def #{association}(force_save=false)
              (_get_#{association} || build_#{association}).tap do |mount|
                mount.save if force_save && !mount.persisted?
              end
            end

            alias :_set_#{association}= :#{association}=

            def #{association}=(mount)
              #{init_method}(mount) if mount.present?
              _set_#{association}= mount
            end

            delegate :url,
                :to => :#{association}, :prefix => true, :allow_nil => true
          RUBY

          if options[:versions]
            options[:versions].each do |version, version_options|
              m = options[:prefix_version] ? "#{association}_#{version}" : version
              mounts_image m, version_options.merge(:parent => association)
            end

            options[:versions] = options[:versions].keys
          end
        end

        self.image_mounting_options[association.to_s] = options

        class_eval(eval_code, __FILE__, __LINE__)
      end

      def mounts_images(association='images', options={})
        mounts_image association, options.merge(:collection => true)
      end
    end
  end
end
