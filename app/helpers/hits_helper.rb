module HitsHelper
  #def hittable_link_text(hittable, text = nil)
    ## NOTE some change has caused hits_date to become a Date, not a String.  rails3, mysql2, w/e.  So check and parse:
    #hits_date = Date === hittable.hits_date ? hittable.hits_date : Date.parse(hittable.hits_date)

    #''.tap do |html|
      #html.concat content_tag(:span, "#{I18n.l(hits_date)} - ", :class => 'hit-date')
      #html.concat content_tag(:span, text || hittable.title, :class => 'hit-link')
      #html.concat content_tag(:span, "(#{hittable.hits_count})", :class => 'hit-count')
    #end.html_safe
  #end

  #def hittable_link(hittable)
    #link_to hittable_link_text(hittable), hittable.url
  #end

end
