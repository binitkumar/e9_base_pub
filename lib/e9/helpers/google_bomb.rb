module E9::Helpers
  module GoogleBomb
    extend ActiveSupport::Concern

    GOOGLE_BOMB_KEYWORDS = <<-KEYWORDS.split(/\n/).map {|n| n.strip }.freeze
      new york web design
      web design new york
      ny web design
      new york website design
      new york graphic design
      web design nyc
      website design new york
      graphic design new york
      website design ny
      nyc web design
      nyc graphic design
      web design ny
      graphic design nyc
      ny graphic design
      graphic designer new york
      new york web design company
      graphic design ny
      website design nyc
      web development new york
      web design new york city
      new york city web design
      graphic designer nyc
      web designers nyc
      web design company new york
      web designer new york
      website design new york city
      new york web designer
      new york web development
      new york city graphic design
      web designer nyc
      web designers new york
    KEYWORDS

    included do
      send :helper_method, :google_bomb_index, :google_bomb_target, :google_bomb_keywords
      send :helper, HelperMethods
    end

    def google_bomb_keywords(index=0)
      GOOGLE_BOMB_KEYWORDS[ index % GOOGLE_BOMB_KEYWORDS.length ]
    end

    def google_bomb_target
      'http://www.e9digital.com'
    end

    def google_bomb_index
      raise 'Current page not persisted' unless current_page.persisted?
      Rails.logger.debug "Google bomb index: #{current_page.id}"
      current_page.id
    rescue => e
      Rails.logger.debug "Google bomb index: 0 (#{e.message})"
      0
    end

    module HelperMethods
      def link_to_google_bomb
        link_to google_bomb_keywords(google_bomb_index), google_bomb_target, :rel => 'external'
      end
    end

    protected :google_bomb_target, :google_bomb_keywords, :google_bomb_index
  end
end
