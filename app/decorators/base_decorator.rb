require 'draper'

class BaseDecorator < Draper::Base

  delegate :is_a?, :kind_of?, :to => :model

  protected

    def regions_html_hash
      {}.tap do |regions|
        if model && model.kind_of?(E9::Models::View)
          h.render_in_html_lookup_context do
            model.regions.for_role("guest").each do |region|
              regions[region.domid] = h.render_region(region.domid, :view => model)
            end
          end
        end
      end
    end

    def html_render
      h.render_in_html_lookup_context do
        yield
      end
    end
end
