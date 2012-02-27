class Admin::CommentsController < Admin::ResourceController

  belongs_to :user, :optional => true

  respond_to :html, :only => :index
  respond_to :js,   :only => :delete_all

  filter_access_to :delete_all, :flagged, :require => :delete, :context => :admin

  has_scope :flagged, :only => :flagged, :type => :boolean, :default => 'true'

  before_filter :add_admin_users_breadcrumb

  def index
    collection
    set_breadcrumb_and_title
    index!
  end

  def flagged
    @toolbar_help_key = :flagged_toolbar_help
    collection
    set_breadcrumb_and_title
    index! do |format|
      format.html { render :index }
    end
  end

  def delete_all
    @user = User.find(params[:user_id], :include => {:comments => :flag})

    @user.comments.each do |comment|
      comment.delete!(:deleter => current_user)
    end
    
    respond_with(@comments = @user.reload.comments.paginate(pagination_parameters))
  end

  protected

  def collection
    @comments ||= end_of_association_chain.includes(:author).paginate(pagination_parameters)
  end

  def add_admin_users_breadcrumb
    #add_breadcrumb! e9_t(:admin_users_breadcrumb), :admin_users_path
  end

  def set_breadcrumb_and_title
    add_breadcrumb! User.model_name.human.pluralize, :admin_users_path if parent?
    add_breadcrumb! admin_comments_title
  end

  def admin_comments_title
    @admin_comments_title ||= begin
      args = {}
      args[:scope]    = parent? ? :"admin.users.comments" : :"admin.comments"
      args[:username] = (parent.username.presence || parent.email) if parent?

      e9_t(params['action'] == 'flagged' ? :flagged_index_title : :index_title, args).titleize
    end
  end
  helper_method :admin_comments_title

end
