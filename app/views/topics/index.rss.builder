xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @forum.try(:rss_title) || current_page.try(:title)
    xml.description nil
    xml.link request.url

    collection.each do |topic|
      xml.item do
        xml.title topic.rss_title
        xml.description topic.rss_description
        xml.pubDate topic.rss_date
        xml.link topic.url
      end
    end
  end
end
