module E9::Liquid::Filters
  module UriEscapeFilter
    def uri_escape(input)
      URI.escape(input) rescue input
    end
  end

  Liquid::Template.register_filter(UriEscapeFilter)
end
