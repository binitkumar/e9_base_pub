module E9::SimpleAttributeMethods
  extend ActiveSupport::Concern
  include ActiveModel::AttributeMethods

  included do
    attribute_method_suffix ""
  end

  attr_writer :attributes
  def attributes; @attributes ||= {} end

  def attribute(attr_name)
    attributes[attr_name]
  end

  def method_missing(method_id, *args, &block)
    if !self.class.attribute_methods_generated?
      self.class.define_attribute_methods(attributes.keys.map(&:to_s))
      send(method_id, *args, &block)
    else
      super
    end
  end
end
