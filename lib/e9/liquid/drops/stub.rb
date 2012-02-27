class E9::Liquid::Drops::Stub < Liquid::Drop
  def method_missing(method, *args, &block)
    "[[#{method.to_s}]]"
  end
end
