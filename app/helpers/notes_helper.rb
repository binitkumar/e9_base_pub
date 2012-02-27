module NotesHelper
  def notes_form(notable, options = {}, &block)
    active = options.delete(:active)
    active = true if active.nil?

    query_params = options.delete(:query_params) || {}

    url_params = options.delete(:url_params) || {}
    url_params.merge!(:parent => notable)

    css_class = "notes-form #{active ? 'notes-active' : 'notes-completed'}"

    form_options = {}.tap do |args|
      args[:method]                       = :get
      args[:class]                        = css_class
      args['data-paging']                 = options[:paging].present?
      args['data-empty']                  = e9_t(:no_notes_text)
      args['data-completed-notes-header'] = e9_t(:completed_notes_header)
      args['data-active-notes-header']    = e9_t(:active_notes_header)
      args['data-per-page']               = E9::Config[:notes_per_page] || 10

      query_params.each do |key, val|
        args["data-query-#{key}"] = val
      end
    end

    form_tag note_form_url(url_params), form_options, &block
  end

  def note_form_url(options = {})
    if parent = options.delete(:parent)
      options["#{parent.class.model_name.element}_id"] = parent.id
    end

    if note = options.delete(:note)
      # Note may be a note or a task, so need polymorphic paths
      note.persisted? ? edit_polymorphic_path(note, options) : new_polymorphic_path(note, options)
    else
      # The index however is always notes path (there is no HTML tasks index)
      notes_path(options)
    end
  end
end
