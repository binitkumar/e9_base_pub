class CreateRenderableRegionTypeJoin < ActiveRecord::Migration
  def self.up
    create_table :region_types_renderables, :id => false do |t|
      t.references :region_type, :renderable
    end
  end

  def self.down
    drop_table :region_types_renderables
  end
end
