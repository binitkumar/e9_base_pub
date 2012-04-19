module E9
  module Permalink
    extend ActiveSupport::Concern
    include HTML

    included do
      #
      # NOTE this first permalink assigment is temporary, with UUID
      #      Implement the actual assign with another callback later
      #      on to assign the real permalink
      #
      before_validation :assign_permalink
      validates :permalink, :uniqueness => true

      # The column which is used 
      class_attribute :permalinked_column
      self.permalinked_column = :title

      # Force the generation of the permalink every save.  Note that classes
      # with this option enabled will never generate UUID appended permalinks
      class_attribute :always_generate_permalink
      self.always_generate_permalink = false

      attr_accessor :preserve_permalink
    end

    module ClassMethods
      def permalink_exists?(permalink)
        permalink = permalink.sub(/^\//, '').sub(/\.\w+$/, '')
        base_class.exists?(:permalink => permalink)
      end

      def permalinkify(string)
        sanitize_and_strip(string).to_slug
      end

      def permalink_for(record)
        to_permalink = record.send(permalinked_column)

        # generate a permalink using UUID if applicable
        if should_uuid_permalink?(record)
          permalink = permalinkify("#{to_permalink}-#{E9.uuid}")

        else 
          # otherwise, attempt to permalinkify the appropriate attribute
          permalink = permalinkify(to_permalink)

          # but if it's taken, append the object's id
          if permalink_exists?(permalink)
            permalink = permalinkify("#{to_permalink}-#{record.id}") 
          end
        end
        
        permalink
      end

      def should_uuid_permalink?(record)
        # don't generate a UUID for new records
        return false if record.persisted?

        # don't generate a UUID if the permalink exists and preserve_permalink
        # is set
        return false if record.preserve_permalink

        # don't generate a UUID for records that are set to always generate
        # permalinks
        return false if always_generate_permalink

        true
      end
    end

    def assign_permalink(options = {})
      self.permalink = nil if options[:force] || self.class.always_generate_permalink
      self.permalink ||= self.class.permalink_for(self)
    end

    def assign_permalink!
      assign_permalink(:force => true)
      save(:validate => false)
    end

    protected :assign_permalink, :assign_permalink!
  end
end
