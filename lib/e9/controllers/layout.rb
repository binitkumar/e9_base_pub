module E9::Controllers
  #
  # This is included into ActionController::Base, changing the default layout
  # lookup behavior for all controllers in the app.
  #
  module Layout
    extend ActiveSupport::Concern

    module ClassMethods
      def inherited(klass)
        super
        klass.send :layout, :determine_layout
      end
    end

    protected

      #
      # application controller will attempt to determine layout based on params 
      # or current page unless it is specified on the subclass
      #
      def determine_layout
        return @__layout if @__layout
        return false if params[:_no_layout] || request.xhr?

        @__layout ||= current_page.layout.try(:template) if current_page.present? 
        @__layout ||= 'application/default'
        @__layout
      end

  end
end
