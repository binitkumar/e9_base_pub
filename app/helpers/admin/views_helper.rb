module Admin::ViewsHelper
  def remove_link_unless_new_record(fields)
    # TODO formerly this added a "do not destroy" accepts_nested_attributes_for value, but I think I fixed it elsewhere
    #out << fields.hidden_field(:_destroy, :value => '0') unless fields.object.new_record?
    text = e9_t(:remove_link)
    content_tag(:a, text, :alt => text, :title => text, :class => 'remove-node')
  end

  def generate_html(form_builder, method, opts = {})
    #opts[:object]  ||= form_builder.object.class.reflect_on_association(method).klass.new
    opts[:object]  ||= Node.new
    opts[:partial] ||= "admin/views/#{method.to_s.singularize}"
    opts[:form_builder_local] ||= :f

    form_builder.fields_for(method, opts[:object], :child_index => 'NEW_RECORD') do |f|
      render(:partial => opts[:partial], :locals => { opts[:form_builder_local] => f })
    end
  end

  def generate_template(form_builder, method, opts = {})
    escape_javascript generate_html(form_builder, method, opts)
  end

  def node_template(form_builder)
    # NOTE 'node_template' rather than node just becuase of field_for's way of inserting the id input
    # tag AFTER the yield.  e.g. <li>form fields</li><input tag>
    # Can't understand why it works that way, but having a duplicate node form is simpler
    # than building a case for it
    @node_template ||= generate_template(form_builder, :nodes, :partial => "admin/views/node_template")
  end

  def node_template_defined?
    !!@node_template
  end

  def preview_page_link(page)
    link_to_new_window e9_t(:preview_link), page.url
  end

  def published_status_select_array
    [[Page::Status::DRAFT, false], [Page::Status::PUBLISHED, true]]
  end

  def published_status_text(page)
    txt, cla = if page.published?
                 [ e9_t(:status_published, :scope => :"admin.views"), 'published-status published' ]
               else
                 [ e9_t(:status_unpublished, :scope => :"admin.views"), 'published-status unpublished' ]
               end

    ''.tap do |html|
      html << content_tag(:span, txt, :class => cla)
      html << content_tag(:span, "(#{page.role})", :class => "viewable-status")
    end.html_safe
  end

  def editable_regions_for_view(view)
    @_editable_regions_for_view ||= {}
    @_editable_regions_for_view[view.hash] ||= view.regions_editable_by_user(current_user).sort_by {|region| region.name.downcase }
  end

  def editable_regions_for_view?(view)
    !editable_regions_for_view(view).blank?
  end

  def renderables_for_region(region, opts)
    klass = opts[:klass] || Renderable

    @renderables_for_region ||= {}
    @renderables_for_region[region.name] ||= klass.for_region(region, opts.slice(:all)).for_roleable(current_user).sort_by {|r| r.form_field_name.downcase }
  end

  def renderables_for_region_select_options(region, opts = {})
    options = renderables_for_region(region, opts).map {|r| [r.form_field_name, r.id] }

    # current being the "current" renderable, versus a no-choice option.
    # Renderable.for_region by default will not return any renderables
    # already in use in the region.  If you send current it will prepend
    # it to the array of options (the current snippet).
    if current = opts[:current]
      options.unshift [current.form_field_name, current.id]
    else
      options.unshift [e9_t(:no_region_select_option), nil]
    end

    options_for_select(options)
  end

  def author_select_options
    possible_authors.sort_by {|author| author.name.downcase }.map {|u| [u.name, u.id] }
  end

  def author_avatar_url_map
    Hash[possible_authors.map {|author| [author.id, author.thumb.url] }]
  end

  def possible_authors
    @_possible_authors = User.authors.all
  end

  def content_publish_link(*args)
    if args.last.published?
      link_to e9_t(:unpublish), polymorphic_path(args.unshift(:unpublish_admin)), :method => :put, :class => 'publish-link', :remote => true
    else
      link_to e9_t(:publish), polymorphic_path(args.unshift(:publish_admin)), :method => :put, :class => 'publish-link', :remote => true
    end
  end
end
