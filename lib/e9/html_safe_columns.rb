module E9
  #
  # Makes use of AttributeMethods to implement a simple aliased method for columns that should be html_safe by default,
  # making it it simpler for HTML templates to be output from the database.
  #
  # NOTE it's presumed that this module will be included by ActiveRecord::Base or a class that acts like it
  #
  module HtmlSafeColumns
    extend  ActiveSupport::Concern
    include ActionView::Helpers::SanitizeHelper

    included do
      attribute_method_suffix "_with_html_safe"

      class_inheritable_accessor :html_safe_column_names
      self.html_safe_column_names = []

      before_validation :sanitize_html_safe_columns
    end

    def sanitize_html_safe_columns
      if self.class.html_safe_column_names.present?
        self.class.html_safe_column_names.each do |column|
          begin
            write_attribute column, sanitize(send(self.class.send(:unsafe_attribute_method_name, column))).try(:strip)
          rescue => e
            Rails.logger.error("HTMLSafeColumns: #{e.message}")
          end
        end
      end
    end
    protected :sanitize_html_safe_columns

    module ClassMethods

      # Call with the columns that should be "html_safe"
      #
      # This invocation does 2 things to the specified columns:
      #
      #   1.) They will be sanitized by the WhiteListSanitizer before validation.
      #   2.) Their attributes will be aliased to columns which are automatically deemed "html_safe", making it unnecessary to render them so in views.
      #
      def html_safe_columns(*args)
        self.html_safe_column_names = args
        undefine_attribute_methods
      end

      def define_method_attribute_with_html_safe(attr_name)
        # NOTE despite the name this hook doesn't define a _with_html_safe method
        #      but rather it aliases the default attriubute to _without_html_safe
        #      and redefines it to return the value in an ActiveSupport::Safebuffer
        #
        if self.html_safe_column_names.map(&:to_s).include?(attr_name.to_s)
          unsafe_method_name = unsafe_attribute_method_name(attr_name)

          class_eval <<-STR, __FILE__, __LINE__ + 1
            if !method_defined?(:#{unsafe_method_name})
              alias :#{unsafe_method_name} :#{attr_name}
            end

            def #{attr_name}; ActiveSupport::SafeBuffer.new(#{unsafe_method_name} || '') end
          STR
        end
      end

      def unsafe_attribute_method_name(attr_name)
        "#{attr_name}_without_html_safe"
      end

      protected :define_method_attribute_with_html_safe, :unsafe_attribute_method_name
    end
  end
end
