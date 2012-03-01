module Admin::LayoutsHelper
  def available_layouts(opts = {})
    scope = Layout.for_roles(current_user.roles)
    scope = scope.for_page_class(opts[:page_class]) if opts[:page_class]
    scope
  end

  def available_layout_select_options(options = {})
    # Sort is by parent_id.to_s then name, so that parent should come first ('' < '1')
    retv = available_layouts(options).sort_by {|layout| [layout.parent_id.to_s, layout.name] }.map {|layout| [layout.name, layout.id] }
    retv.unshift [e9_t(:layout_select_text), nil] unless options[:no_default]
    retv
  end

  def change_to_layout_link(layout, view, options = {})
    scope = options.delete(:scope) || :"admin.views"

    if view.layout != layout
      url = polymorphic_path [:change_layout_admin, resource], :layout_id => layout.id

      options.merge!(:method => :put)
      
      link_to options.delete(:contents) || e9_t(:select_layout_link, :scope => scope), url, options
    else
      options.delete(:contents) || content_tag(:span, e9_t(:current_layout_label, :scope => scope))
    end
  end

  def layout_preview_tag(layout)
    image_tag "defaults/layout_previews/#{layout.default_image_name}.png"
  end

  def layout_image_tag(layout)
    image_tag "defaults/layout_images/#{layout.default_image_name}.png"
  end
end
