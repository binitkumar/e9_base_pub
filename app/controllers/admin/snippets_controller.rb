class Admin::SnippetsController < Admin::RenderablesController

  filter_access_to  :revert, :require => :update, :context => :admin
  use_tiny_mce      :only => [:edit, :create, :update, :new]
  add_resource_breadcrumbs

  # NOTE this is just like #replace on the superclass except it doesn't
  #      pass the node_id
  def new
    if clone_target = resource_class.find_by_id(params[:id])
      set_resource_ivar(clone_target.clone)
    end

    new!
  end

  def revert
    object = resource
    object.revert_template!

    respond_with(object) do |format|
      format.html { redirect_to collection_url }
      format.js { head :ok }
    end
  end
end
