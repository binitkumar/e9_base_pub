class DealDecorator < BaseDecorator
  decorates :deal

  def as_json(options={})
    {}.tap do |hash|
      hash[:id]   = model.id
      hash[:type] = 'deal'
      hash[:name] = model.name
      hash[:url]  = model.url

      if deal.lead? && model.offer
        # NOTE could probably make an offer_decorator ...
        offer = {}

        offer[:id]      = model.offer.id
        offer[:name]    = model.offer.name
        offer[:cookied] = offer_cookied?(model.offer)

        # NOTE unlike most decorators this always renders HTML
        html_render do
          offer[:form] = h.render('e9_crm/leads/form', :resource => model)
        end

        offer[:body] = h.render_liquid(model.offer.template, 'offer' => model.offer)
        offer[:success_page] = model.offer.options.success_page_text

        hash[:offer] = offer
      end
    end
  end

  private

    def offer_cookied?(offer_or_id)
      offer_or_id = offer_or_id.id if offer_or_id.respond_to?(:id)

      cookied_offer_array = Marshal.load(h.cookies['_e9_offers'])
      cookied_offer_array.member?(offer_or_id.to_i)
    rescue
      false
    end

end
