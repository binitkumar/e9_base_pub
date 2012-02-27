class Admin::ForumsController < Admin::CategoriesController
  include E9::Controllers::View
  carrierwave_column_methods :thumb, :context => :admin
end
