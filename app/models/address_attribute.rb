# Attribute for address info
#
class AddressAttribute < RecordAttribute
  def to_s
    ''.tap do |html|
      html << "(#{options.type})<br />" if options.type.present?
      html << value.gsub(/\n/, '<br />')
    end.html_safe
  end

  def url
    "http://maps.google.com/maps?q=#{CGI.escape(value)}"
  end

  def link(text = 'Map')
    %Q{<a href="#{url}" rel="external">#{text}</a>}.html_safe
  end
end
