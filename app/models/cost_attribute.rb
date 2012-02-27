class CostAttribute < RecordAttribute
  self.options_parameters = [:label, :promo_code_required]

  money_columns :value

  ##
  # A little hackery to make money columns work with a string
  #

  def value
    Money.new(read_attribute(:value).presence.try(:to_i) || 0)
  end

  def cents
    value.cents
  end

  def to_s
    "#{options.label} (#{value.format})"
  end
end
