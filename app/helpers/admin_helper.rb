module AdminHelper
  def render_admin_form(options = {})
    options.reverse_merge!(:container => true)

    ''.html_safe.tap do |html|

      if options[:container]
        html.concat(content_tag :div, render('form'), :id => 'form')
      else
        html.concat(render('form'))
      end

      html.concat(render 'shared/admin/tiny_mce') if use_tiny_mce?
    end
  end

  def resource_model_name
    @resource_model_name ||= resource_class.model_name.human rescue ''
  end

  def resource_humanize(attr)
    resource_class.human_attribute_name(attr) rescue ''
  end

  def quick_edit_admin_resource_link(resource, opts = {})
    text = opts.delete(:text) || e9_t(:quick_edit_link)
    link_to(text, polymorphic_path([:quick_edit, :admin, [*opts.delete(:scopes)], resource].flatten.compact), opts)
  end

  def admin_resource_index_link(klass, opts = {})
    klass = klass.is_a?(Class) ? klass : klass.to_s.classify.constantize
    text = opts.delete(:text) || e9_t(:index_title, :models => klass.model_name.human.pluralize)
    link_to(text, polymorphic_path([:admin, [*opts.delete(:scopes)], klass].flatten.compact), opts)
  end

  def edit_admin_resource_link(resource, opts = {})
    text = opts.delete(:text) || e9_t(:edit_link)
    link_to(text, edit_polymorphic_path([:admin, [*opts.delete(:scopes)], resource].flatten.compact), opts)
  end

  def new_admin_resource_link(klass, opts = {}, &block)
    klass = klass.is_a?(Class) ? klass : klass.to_s.classify.constantize
    text = opts.delete(:text) || e9_t(:add_link, :model => klass.model_name.human)
    link_to(text, new_polymorphic_path([:admin, [*opts.delete(:scopes)], klass, opts.delete(:polymorphic_args)].flatten.compact, opts.delete(:path_args) || {}), opts, &block)
  end

  def show_admin_resource_link(resource, opts = {})
    text = opts.delete(:text) || e9_t(:show_link, :model => resource.class.human_name)
    link_to(text, polymorphic_path([:admin, [*opts.delete(:scopes)], resource].flatten.compact), opts)
  end

  def destroy_admin_resource_link(resource, opts = {}, &block)
    text = opts.delete(:text) || e9_t(:delete_link)
    opts.reverse_merge!({
      :confirm => opts.delete(:confirm) || e9_t(:confirmation_question),
      :method  => :delete,
      :remote  => true
    })
    link_to(text, polymorphic_path([:admin, [*opts.delete(:scopes)], resource].flatten.compact, opts.delete(:path_args) || {}), opts, &block)
  rescue
    link_to(text, polymorphic_path([opts.delete(:scopes), resource].flatten.compact, opts.delete(:path_args) || {}), opts, &block)
  end

  def new_with_layout_form(klass, options = {}, &block)
    options.symbolize_keys!

    url = options[:url] || new_polymorphic_path([:admin, klass])

    form_for(klass.new, :url => url, :html => { :method => :get }) do |f|
      f.label(:layout_id, I18n.t(:new_with_layout, :model => klass.model_name.human, :scope => 'activerecord.links')) +
      f.select(:layout_id, available_layout_select_options(:page_class => klass, :no_default => true)) +
      f.submit(I18n.t(:go), :name => nil)
    end
  end

  def toolbar_actions(&block)
    toolbar_capture('toolbar-actions action-buttons',  &block)
  end

  def toolbar_filters(&block)
    toolbar_capture('toolbar-filters', :toolbar_filters, &block)
  end

  def toolbar_forms(&block)
    toolbar_capture('toolbar-forms', &block)
  end

  def toolbar_help(&block)
    toolbar_capture('toolbar-help', :toolbar_help, &block)
  end

  def toolbar_capture(css_class, label_key=nil, &block)
    content = with_output_buffer(&block)

    if label_key
      content = content_tag(:div, I18n.t(label_key), :class => 'toolbar-header') << content
    end

    content_tag(:div, content, :class => css_class)
  end

  def tool_buttons(&block)
    ''.html_safe.tap do |html|
      html << content_tag(:span, t(:tool_button), :class => 'tool-button icon-tools', :rel => 'tooltip')
      html << content_tag(:div, with_output_buffer(&block), :class => 'tooltip tool-buttons')
    end
  end

  def ordered_on_link(klass, column_name, override_name = nil)
    if respond_to?(:orderable_column_link)
      orderable_column_link(column_name, override_name)
    end

    #link_text = klass.human_attribute_name(override_name || column_name)

    #body = if (sc = controller.try(:scopes_configuration)) && sc.has_key?(:ordered_on)
      #column_name = column_name.join(',') if column_name.is_a?(Array)

      #if params['ordered_on'] == column_name.to_s
        #curr_order, link_order = case params[:dir]
          #when /^desc$/i then %w(desc asc)
          #else                %w(asc desc)
        #end
      #else
        #curr_order = nil
        #link_order = controller.respond_to?(:default_order_dir) ? controller.send(:default_order_dir) : 'asc'
      #end

      #css_classes = ["order-gfx", curr_order, "h-#{link_order}"].compact.join(' ')

      #content_tag(:div, :class => 'ordered-column') do
        #''.html_safe.tap do |html|
          #html << link_to(link_text, query_params.merge(:ordered_on => column_name, :dir => link_order), :remote => true)
          #html << tag(:span, :class => css_classes)
        #end
      #end
    #else
      #link_text
    #end
  end
end
