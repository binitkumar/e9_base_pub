class Admin::FaqsController < Admin::CategoriesController

  has_role_scope :only => :index, :exact => true

  protected

  def resource
    get_resource_ivar || set_resource_ivar(end_of_association_chain.find(params[:id]))
  end
end
