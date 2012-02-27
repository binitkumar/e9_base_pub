# Attribute for related websites, e.g. Facebook Page, Personal Website
#
class WebsiteAttribute < RecordAttribute

  IPv4_PART = /\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]/ # 0-255

  # First regexp doesn't work in Ruby 1.8 and second has a bug in 1.9.2:
  # https://github.com/henrik/validates_url_format_of/issues/issue/4/#comment_760674
  ALNUM = /[[:alnum:]]/

  REGEXP = %r{
    \A
      https?://
      ([^\s:@]+:[^\s:@]*@)?
      ( ((#{ALNUM}+\.)*xn--)?#{ALNUM}+([-.]#{ALNUM}+)*\.[a-z]{2,6}\.? |
      #{IPv4_PART}(\.#{IPv4_PART}){3} )
      (:\d{1,5})?
      ([/?]\S*)?
    \Z
  }iux

  validates :url, :format => { :with => REGEXP, :allow_blank => true}

  def url
    value.blank? || value =~ /^\w+?:\/\// ? value : "http://#{value}"
  end

  def to_html
    %Q{<a href="#{url}" rel="external nofollow">#{value}</a> #{options.type.present? && "(#{options.type})"}}.html_safe
  end
end
