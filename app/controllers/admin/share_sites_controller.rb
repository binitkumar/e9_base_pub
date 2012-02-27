class Admin::ShareSitesController < Admin::ContentController
  include E9::Controllers::Sortable

  respond_to :js, :html

  filter_access_to :update_order, :toggle_enabled, :require => :update, :context => :admin

  add_resource_breadcrumbs :admin => true

  # NOTE common pattern here? see 4 methods in a row that redefine the responder redirect. this happens all over, should probably find a better way

  def create
    create! do |success, failure|
      success.html { redirect_to admin_share_sites_path }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to admin_share_sites_path }
    end
  end

  def update_order
    update_order! do |format|
      format.html { redirect_to admin_share_sites_path }
      format.js { render :reload_table }
    end
  end

  def toggle_enabled
    object = resource
    
    object.update_attribute(:enabled, !object.enabled)

    respond_with(collection) do |format|
      format.html { redirect_to admin_share_sites_path }
      format.js { render :reload_table }
    end
  end

  protected
  
  ##
  # IR
  # 
  def collection 
    @share_sites ||= end_of_association_chain.ordered.all
  end

  def enabled_count
    [E9::Config[:maximum_share_site_count], ShareSite.enabled.count].min
  end
  helper_method :enabled_count


end
