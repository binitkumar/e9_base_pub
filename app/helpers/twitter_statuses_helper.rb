module TwitterStatusesHelper
  def twitter_pagination_link(wp_collection)
    if next_page = wp_collection.next_page
      link_to("Show More", twitter_statuses_path(:page => next_page, :per_page => wp_collection.per_page), :remote => true)
    end
  end

  TWITTER_TOPIC_URI_TEMPLATE = "<a href=\"http://twitter.com/#!/search?q=%s\" rel=\"external\">%s</a>"
  TWITTER_AT_URI_TEMPLATE    = "<a href=\"http://twitter.com/%s\" rel=\"external\">%s</a>"

  def twitter_parse(status)
    status = auto_link(status, :html => { :rel => :external }, :link => :urls, :sanitize => false)
    status.gsub!(/#[^\s#]+/) {|match| TWITTER_TOPIC_URI_TEMPLATE % [URI.escape(match), match] }
    status.gsub!(/@[^\s@]+/) {|match| TWITTER_AT_URI_TEMPLATE    % [URI.escape(match[1..-1]), match] }
    status.html_safe
  end
end
