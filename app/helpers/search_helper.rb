module SearchHelper
  def excerpt_or_snippet(text, query = nil, length = nil)
    text = strip_tags(text)
    return unless text.present?

    # if both query and length passed, try to excerpt, if the query is not found in
    # the text this will return nil
    html = if query.present? && length
      excerpt(text, query, :radius => [((length - query.length) / 2).floor, 0].max)
    end

    # if length was passed (and html was not set previously) truncate based on length
    html ||= length ? truncate(text, :length => length) : text

    if html
      # finally try to highlight if query was passed
      html = highlight(html, query) if query.present?

      html.html_safe
    end
  end

  def feed_title_excerpt_or_snippet(text, query, length = nil)
    excerpt_or_snippet(text, query, nil)
  end

  def feed_summary_excerpt_or_snippet(text, query, length = nil)
    excerpt_or_snippet(text, query, length || E9::Config[:feed_summary_characters])
  end

  # TODO remove
  def add_edit_listing_action_if_applicable(listing, admin_scope = true)
    if admin?
      path_args = [listing]
      path_args.unshift(:admin) if admin_scope
      add_actions_list_item link_to(e9_t(:edit_link), edit_polymorphic_path(path_args)) 
    end
  rescue => e
    # rescue in case the model listed has no admin edit path
  ensure
    nil
  end

  def show_more_link(klass, wp_results, search)
    if wp_results.next_page
      link_text = e9_t(:show_more_link, :count => calculate_remaining_records(wp_results)) 

      link_to(link_text, searches_path(:id => search.id, :query => search.query, :page => wp_results.next_page, :search_type => klass.model_name.element), {
        :remote => true
      })
    end
  end

  private

  def calculate_remaining_records(wp_results)
    [wp_results.per_page, wp_results.total_entries - wp_results.current_page * wp_results.per_page].min
  end
end
