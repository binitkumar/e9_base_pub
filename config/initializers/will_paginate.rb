#require 'i18n'
# TODO setting the load path this way is probably redundent
#I18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}').to_s]

require 'will_paginate/view_helpers'
require 'will_paginate/view_helpers/link_renderer'
require 'will_paginate/array'

WillPaginate::ViewHelpers.pagination_options[:previous_label] = "&lt; Previous"
WillPaginate::ViewHelpers.pagination_options[:next_label] = "Next &gt;"
WillPaginate::ViewHelpers.pagination_options[:inner_window] = 2
WillPaginate::ViewHelpers.pagination_options[:outer_window] = 0

# Oddly, the new will_paginate removed the options to set a global default
# link_renderer, so now we just override methods on the inner class.  Neat! (?)
#
class WillPaginate::ViewHelpers::LinkRenderer
  def to_html
    html = pagination.each_with_index.map do |item, i|
      val = item.is_a?(Fixnum) ?  page_number(item) : send(item)
      tag(:li, val, :class => pagination.length - 1 == i ? 'last' : nil) 
    end.join
    
    # always render in container
    html_container(html)
  end

  def html_container(html)
    tag(:ul, html, container_attributes)
  end
end
