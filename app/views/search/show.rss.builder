xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @search.rss_title
    xml.description @search.rss_description
    xml.link request.url

    @search.results_by_date.each do |result|
      xml.item do
        xml.title result.rss_title
        xml.description result.rss_description
        xml.pubDate result.rss_date.to_formatted_s(:rfc822)
        xml.link result.try(:url)
      end
    end
  end
end
