module ImagesHelper
  def all_image_tags
    @_all_image_tags ||= begin
      sql = Tag.joins(:taggings).
          merge(Tagging.where(:context => E9Tags.escape_context('images*'))).
          select("DISTINCT tags.name").
          order("tags.name ASC").to_sql

      Tag.connection.select_values(sql)
    end
  end

end
