module E9::Controllers
  # A hackish has_scope mixin to allow ordering by database column.
  #
  # Requires has_scope and inherited_resources.
  #
  module Orderable
    extend ActiveSupport::Concern

    included do
      helper HelperMethods

      helper_method :default_ordered_dir

      has_scope :order, :if => :ordered_if, :default => lambda {|c| c.send(:default_ordered_on) } do |controller, scope, columns|
        resource_class = controller.send(:resource_class)

        begin
          # determine the dir from params or controller default
          dir = case controller.params[:sort]
                when /^desc$/i then 'DESC'
                when /^asc$/i  then 'ASC'
                else controller.try(:default_ordered_dir) || ''
                end

          # split the ordered_param on commas and periods, the idea being that 
          # it can take multiple columns, and on assocation columns
          columns = columns.split(',').map {|n| n.split('.') }

          columns = columns.map {|v| 
            # if column split on '.', try to constantize the parsed class
            if v.length > 1 && v.last =~ /\w+/
              klass = v.first.classify.constantize rescue nil

              if klass && resource_class.reflect_on_association(klass.table_name)
                scope = scope.includes(v.first.underscore.to_sym)
                "#{klass.table_name}.#{v.last} #{dir}"
              else
                "#{v.join('.')} #{dir}"
              end
            elsif v.last =~ /\w+/
              sql = ''

              if resource_class.column_names.member?(v.last)
                sql << "#{resource_class.table_name}."
              end

              sql << "#{v.last} #{dir}"
            end
          }.compact.join(', ')

          scope.order(columns)
        rescue => e
          Rails.logger.error("Orderable ordered_on scope : #{e.message}")
          scope
        end
      end
    end

    def default_ordered_on 
      'created_at' 
    end

    def default_ordered_dir 
      'DESC' 
    end

    def ordered_if 
      params[:action] == 'index' 
    end

    module HelperMethods
      def orderable_column_link(column, override_name = nil)
        link_text = %Q[<span class="text">#{resource_class.human_attribute_name(override_name || column)}</span>].html_safe

        column = column.join(',') if column.is_a?(Array)

        co, lo = if params[:order] == column.to_s
          params[:sort] =~ /^desc$/i ? %w(DESC ASC) : %w(ASC DESC)
        else
          [nil, default_ordered_dir.presence || 'DESC']
        end

        css_classes = ["order-gfx", co, "h-#{lo}"].compact.join(' ').downcase

        link_text.safe_concat content_tag(:span, "&nbsp;", :class => css_classes)

        content_tag(:span, :class => 'ordered-column') do
          link_to(link_text, :order => column, :sort => lo)
        end
      end
    end
  end
end
