xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Content Feed" # TODO Content Views Title
    xml.description nil
    xml.link request.url

    collection.each do |record|
      xml.item do
        xml.title record.rss_title
        xml.description record.rss_description
        xml.pubDate record.rss_date.to_formatted_s(:rfc822)
        xml.link record.try(:url)
      end
    end
  end
end
