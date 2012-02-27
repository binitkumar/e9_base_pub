class Admin::EventTypesController < Admin::CategoriesController

  protected

    def collection
      get_collection_ivar || set_collection_ivar(end_of_association_chain.order(:position).all)
    end

    def resource
      get_resource_ivar || set_resource_ivar(end_of_association_chain.find(params[:id]))
    end

end
