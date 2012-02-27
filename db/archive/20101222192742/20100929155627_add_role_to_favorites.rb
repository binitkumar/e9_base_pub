class AddRoleToFavorites < ActiveRecord::Migration
  def self.up
    add_column :favorites, :role, :string

    Favorite.reset_column_information
    Favorite.all.each do |favorite|
      favoritable = favorite.favoritable
      if favoritable.respond_to?(:role)
        favorite.role = favoritable.role
        favorite.save(:validate => false)
      end
    end
  end

  def self.down
    remove_column :favorites, :role
  end
end
