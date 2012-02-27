module E9::Controllers
  #
  # Allow view lookup inheritance (which is included by default in Rails 3.1+)
  #
  # Works by storing the current controller's class in the lookup_context. On 
  # missing template errors, it looks up the inheritance chain until finding a 
  # matching template.
  #
  module InheritableViews
    extend ActiveSupport::Concern
    
    included do
      class_inheritable_accessor :inherits_views
      self.inherits_views = true
    end

    def lookup_context
      @_lookup_context ||= 
        InheritingLookupContext.new(
          self.class, self.class._view_paths, details_for_lookup)
    end

    class InheritingLookupContext < ::ActionView::LookupContext
      attr_accessor :controller_class

      def initialize(*args)
        self.controller_class = args.shift
        super(*args)
      end

      def find(name, prefix = nil, partial = false)
        super
      rescue ::ActionView::MissingTemplate
        klass ||= controller_class

        raise $! unless [klass, klass.superclass].all? do |k| 
          k.respond_to?(:inherits_views) && k.inherits_views
        end

        klass  = klass.superclass
        prefix = klass.controller_path

        retry
      end

      alias :find_template :find
    end
  end
end
