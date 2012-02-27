class Admin::LayoutsController < Admin::ContentController
  include E9::Controllers::View

  respond_to :js, :html

  add_resource_breadcrumbs

  def create
    create! { collection_path }
  end

  def update
    update! { collection_path }
  end

  protected

  def build_resource
    @layout ||= if params[:layout]
      end_of_association_chain.new(params[:layout])
    else
      find_parent_layout.prototype!
    end
  end

  def collection
    @layouts ||= end_of_association_chain.for_roleable(current_user)
  end

  def find_parent_layout
    Layout.find_by_id!(params[:layout_id])
  end
end
