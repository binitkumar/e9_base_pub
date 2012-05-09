module E9Crm::OffersHelper
  def records_table_field_map_for_offer
    {
      :fields => { 
        :name => proc {|r|
          val = r.name.dup.html_safe
          val << " *" if r.is_default?

          content_tag(:span, val, :class => r.is_default? ? 'default-offer' : nil)
        }
      },

      :links => proc {|r| [
        link_to_edit_resource(r), 
        link_to_destroy_resource(r),
        link_to_toggle_default_offer(r)
      ]}
    }
  end

  def offer_mailing_lists
    @_offer_mailing_lists ||= begin
      retv =  MailingList.newsletters.all
      retv << MailingList.new_content_alerts
      retv.compact
    end
  end

  def link_to_toggle_default_offer(offer)
    unless offer.is_default?
      query = Rack::Utils.escape("offer[is_default]=1")
      path = "/admin/crm/offers/#{offer.id}?#{query}"

      link_to "Make Default", path, {
        :method => :put,
        :remote => true
      }
    end
  end
end
