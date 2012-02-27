class SchoolAttribute < RecordAttribute
  self.options_parameters = [:type, :year]

  def to_s
    retv = options.type.blank? ? '' : "#{options.type} - "
    retv += "#{value} #{options.year}"
    retv
  end
end
