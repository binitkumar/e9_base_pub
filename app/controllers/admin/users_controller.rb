class Admin::UsersController < Admin::ResourceController
  include E9::Controllers::Orderable

  respond_to :js, :html
  respond_to :json, :only => :show

  filter_access_to :show, :edit, :update, :reset_avatar, :attribute_check => true, :require => :edit, :context => :users

  add_resource_breadcrumbs

  has_scope :search,   :only => :index

  has_scope :of_scope, :default => proc {|c| c.send(:default_scope) }, :only => :index do |c, s, v|
    s.of_scope(v, c.send(:current_user))
  end

  before_filter :prepare_params, :only => :update

  def show
    show! do |format|
      format.html { redirect_to edit_admin_user_path(resource) }
      format.json
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to_back_or(collection_url) }
    end
  end

  def destroy
    if params[:id] == current_user.id.to_s
      flash[:alert] = "You cannot delete your own account!"
      respond_to do |format|
        format.html { redirect_to admin_users_path }
        format.js { head 403 }
      end
    else
      destroy! do |success, failure|
        success.js { head 204, :location => :admin_users }
        failure.js { head 403 }
      end
    end
  end

  def reset_avatar
    object = resource
    object.remove_avatar!
    object.send(:write_attribute, :avatar, nil)
    object.save(:validate => false)
    respond_with(object.reload)
  end

  protected

  ##
  # IR
  # 
  def collection 
    @users ||= end_of_association_chain.for_roleable(current_user).paginate(pagination_parameters)
  end

  ##
  # Filters
  #
  #
  def default_scope
    #@default_scope ||= User.flagged.count > 0 ? 'flagged' : 'default'
    'default'
  end

  def search_scope
    params[:of_scope] || default_scope
  end

  def prepare_params
    # and add blank mailing_list_ids for subscriptions
    params[:user][:mailing_list_ids] ||= []
  end

  ##
  # Misc
  #

  def default_ordered_on
    'username'
  end

  def default_ordered_dir
    'ASC'
  end
end
