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

      class_attribute :permalinked_column
      self.permalinked_column = :title

      class_attribute :always_generate_permalink
      self.always_generate_permalink = false
    end

    module ClassMethods
      def permalink_exists?(permalink)
        base_class.exists?(:permalink => permalink.sub(/^\//,''))
      end

      def permalinkify(string)
        sanitize_and_strip(string).to_slug
      end

      def permalink_for(record)
        to_permalink = record.send(permalinked_column)

        # when a new record, generate a permalink using UUID
        if !always_generate_permalink && record.new_record?
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
