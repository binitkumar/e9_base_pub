module E9::Helpers
  module Breadcrumbs
    extend ActiveSupport::Concern

    included do
      class_inheritable_accessor :should_manage_breadcrumbs
      self.should_manage_breadcrumbs = true

      helper_method :clear_breadcrumbs, :add_breadcrumb!
    end

    def add_new_breadcrumb; end
    def add_show_breadcrumb; end
    def add_index_breadcrumb; end
    def add_edit_breadcrumb; end
    def add_dynamic_breadcrumbs; end

    def add_breadcrumb!(breadcrumb, path = nil)
      add_breadcrumb breadcrumb, path || lambda {|c| c.request.path }
    end

    def clear_breadcrumbs
      @breadcrumbs = []
    end

    module ClassMethods
      CRUD_ACTIONS = [:index, :show, :new, :create, :update, :edit, :destroy]
      NEW_ACTIONS  = [:new, :create]
      EDIT_ACTIONS = [:edit, :update]
      SHOW_ACTIONS = [:show]

      def add_breadcrumb(*args)
        options = args.extract_options!

        before_filter options.merge(:if => :should_manage_breadcrumbs) do |controller|
          controller.send(:add_breadcrumb!, *args)
        end
      end

      def add_dynamic_breadcrumbs
        before_filter :add_dynamic_breadcrumbs
      end

      def add_resource_breadcrumbs(*args)
        options = args.extract_options!

        actions = if options[:only]
                    Array.wrap(options.delete(:only))
                  elsif options[:except]
                    CRUD_ACTIONS - Array.wrap(options.delete(:except))
                  else
                    CRUD_ACTIONS
                  end

        before_filter :add_index_breadcrumb if actions.member?(:index)
        before_filter :add_new_breadcrumb,  options.merge(:only => NEW_ACTIONS & actions)  unless (NEW_ACTIONS & actions).empty?
        before_filter :add_edit_breadcrumb, options.merge(:only => EDIT_ACTIONS & actions) unless (EDIT_ACTIONS & actions).empty?
        before_filter :add_show_breadcrumb, options.merge(:only => SHOW_ACTIONS & actions) unless (SHOW_ACTIONS & actions).empty?
      end
    end
  end
end
