class E9::Liquid::Drops::Category < E9::Liquid::Drops::Linkable
  source_methods :title, :description, :meta_description

  def thumb_url
    @object.try(:thumb_url)
  end

  def thumb_path
    @object.try(:thumb_path)
  end
end
