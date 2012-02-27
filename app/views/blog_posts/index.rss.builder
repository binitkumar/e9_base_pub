xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title sanitize(@blog_title).html_safe
    xml.description @blog ? @blog.rss_description : nil
    xml.link @blog ? @blog.url(:format => :rss) : blogs_url(:format => :rss)

    collection.each do |post|
      xml.item do
        xml.title post.rss_title
        xml.description post.rss_description
        xml.pubDate post.rss_date.to_formatted_s(:rfc822)
        xml.link post.url
      end
    end
  end
end
