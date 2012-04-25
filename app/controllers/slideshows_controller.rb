class SlideshowsController < ApplicationController
  include PublicFacingController
  include E9::Controllers::Sortable

  inherit_resources

  methods :index
  respond_to :json, :only => :index

  add_resource_breadcrumbs

  def index
    index! do |format|
      format.html
      format.json do
        render :json => {
          :type       => 'slideshows',
          :slideshows => collection
        }
      end
    end
  end

  protected

  def collection_scope
    end_of_association_chain.for_role(current_user_or_public_role)
  end

  def collection 
    @slideshows ||= collection_scope.all
  end

  def add_index_breadcrumb
    add_breadcrumb! current_page.title
  end

  def find_current_page
    @current_page ||= Page.slideshows_index || super
  end
end
