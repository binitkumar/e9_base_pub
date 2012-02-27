class UsersController < InheritedResources::Base
  include E9::Controllers::Orderable
  include PublicFacingController

  actions :show, :index

  respond_to :js, :only => :index

  # NOTE this should use User.profile_roles but it does not, rather it's defined
  # in authorization_rules
  filter_access_to :show, :index, :context => :user_profiles

  has_scope :search
  has_scope :profile_roles, :default => 'true' do |_, scope, _|
    scope.profiled
  end

  add_resource_breadcrumbs

  before_filter :determine_index_title

  before_filter :authenticate_user!

  protected

  def filter_target
    Struct.new(:roles).new(User.profile_roles)
  end

  def pagination_per_page_default
    E9::Config[:admin_records_per_page]
  end

  def collection 
    @users ||= end_of_association_chain.paginate(pagination_parameters)
  end

  def find_current_page
    @current_page ||= Page.find_by_identifier(Page::Identifiers::USERS) || SystemPage.master
  end

  def default_ordered_on
    'first_name'
  end

  def default_ordered_dir
    'ASC'
  end

  def add_show_breadcrumb(opts = {})
    @show_title = e9_t(:show_title, :name => resource.name)
    add_breadcrumb! @show_title
  end

  def determine_index_title
    params.delete(:search) if params[:search].blank?

    @index_title = if params[:search]
      e9_t(:index_title_with_search, :search => params[:search])
    else
      e9_t(:index_title)
    end
  end
end
