module E9::Liquid::Filters
  module BitlyFilter
    def bitly(input)
      input.strip!

      uri = URI.parse(input)
      raise "invalid uri" unless uri.scheme

      creds = ENV['BITLY_USERNAME'], ENV['BITLY_API_KEY']
      raise "invalid creds" if creds.any?(&:blank?)

      bitly = Bitly.new(*creds)
      bitly.shorten(uri.to_s).short_url
    rescue => e
      Rails.logger.error("Error generating bitly url for input [#{input}]: #{e.message}")
      input
    end
  end

  Liquid::Template.register_filter(BitlyFilter)
end
