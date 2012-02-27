require 'has_scope'

module HasScope
  alias :parse_value_without_rescue :parse_value
  def parse_value(*args)
    parse_value_without_rescue(*args) rescue nil
  end
end
