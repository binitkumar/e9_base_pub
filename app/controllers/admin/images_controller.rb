class Admin::ImagesController < Admin::ResourceController
  include E9::Controllers::Sortable

  belongs_to :banner, :optional => true

  respond_to :js

  carrierwave_column_methods :file, :context => :admin

  skip_js_skippable_filters
end
