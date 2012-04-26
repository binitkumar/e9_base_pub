class BlogPostsController < ApplicationController
  include PublicFacingController
  inherit_resources

  # NOTE archive mode does NOT work and is only half supported throughout.  
  # It should either be fixed or just removed.
  #
  belongs_to :blog, :finder => :find_by_permalink!, :optional => true

  respond_to :rss, :html, :json
  respond_to :js, :only => :index

  # NOTE
  prepend_before_filter :association_chain

  filter_access_to :index, :show, :attribute_check => true, :load_method => :declarative_auth_dummy, :context => :pages

  before_filter :determine_blog_title
  before_filter :build_blog_posts_for_resource_menu, :only => :show

  add_resource_breadcrumbs

  has_scope :month, :only => :index, :if => :should_group_by_date?, :default => proc {|c| c.send(:default_month) } do |controller, scope, val|
    # if month is passed, it's a reasonable assumption that year is also
    # (the route handles this, unless someone explicitly passes month=XX)
    if val =~ /\d{1,2}/
      year = controller.params[:year].to_s =~ /\d{4}/ ? controller.params[:year] : controller.send(:default_year)
      scope.for_month_and_year(val, year)
    else
      scope
    end
  end
  
  # NOTE year scope is only applied if month not passed
  has_scope :year, :only => :index, :if => :should_group_by_date?, :unless => :month_passed?, :default => proc {|c| c.send(:default_year) } do |controller, scope, val|
    if val =~ /\d{4}/
      scope.for_year(val)
    else
      scope
    end
  end

  has_scope :tagged, :only => :index, :type => :array do |controller, scope, value|
    scope.tagged(value, {
      :any => !E9.true_value?(controller.params[:tagged_all])
    })
  end

  def index
    if !parent && available_blogs.count == 1
      redirect_to available_blogs.first.url and return false
    end

    index! do |format|
      format.json do 
        render :json =>  { 
          :name       => parent && parent.title,
          :layout     => parent && parent.layout && File.basename(parent.layout.template.to_s, '.*'),
          :type       => 'blog',
          :total      => base_collection_scope.count,
          :per_page   => pagination_per_page_default,
          :page       => params[:page] || 1,
          :blog_posts => collection 
        }
      end
    end
  end

  protected
  
  def available_blogs
    @_available_blogs ||= Blog.for_role(current_user_or_public_role)
  end

  def default_month
    (default_post ? default_post.published_at.month : DateTime.now.month).to_s
  end

  def default_year
    (default_post ? default_post.published_at.year  : DateTime.now.year).to_s
  end

  def default_post
    @_default_post ||= @blog_post || end_of_association_chain_before_scopes.for_roleable(current_user).published.recent.limit(1).first
  end

  ##
  # pagination
  #
  def pagination_per_page_default 
    E9::Config[:blog_pagination_records]
  end

  # declarative_authorization requires a "dummy" variable to decide if the page is viewable
  # by the current user. It looks for a variable named for the scope, in this case :pages.  Apparently
  # it can look for a proc/method to determine auth as well, but this is intuitive enough.
  def declarative_auth_dummy
    params[:id] ? BlogPost.find_by_permalink(params[:id]) : BlogPost.new(:blog => parent)
  end

  ##
  # IR
  #
  def collection 
    @blog_posts ||= begin
      objects = if should_group_by_date?
        base_collection_scope.all
      else
        base_collection_scope.recent.paginate(pagination_parameters)
      end

      objects.map! {|object| BlogPostDecorator.decorate(object) }
    end
  end

  def resource
    @blog_post ||= begin
      object = end_of_association_chain.find_by_permalink!(params[:id])
      object.increment_hits!
      BlogPostDecorator.decorate(object)
    end
  end

  def base_collection_scope
    end_of_association_chain.published.for_role(current_user_or_public_role)
  end

  def build_blog_posts_for_resource_menu
    if should_group_by_date?
      params['month'] = resource.published_at.month
      params['year']  = resource.published_at.year
      # has_scope actually makes this a little more awkward than it would be; need to call the scope manually for scopes that would apply to date
      @blog_posts = end_of_association_chain.for_month_and_year(params['month'], params['year'])
    else
      @pagination_parameters[pagination_page_param] = determine_blog_post_page_number(resource)
      @blog_posts = collection
    end
  end

  ##
  # resource breadcrumb impl
  #
  def add_index_breadcrumb
    add_breadcrumb(determine_blog_title, :blogs_path) unless available_blogs.count == 1
    add_breadcrumb parent.title, blog_path(parent) if parent
  end

  def add_show_breadcrumb
    add_breadcrumb! resource.title
  end

  def find_current_page
    @current_page = params[:id] && resource || parent || blog_index_page || super
  end

  ##
  # util
  #
  def month_passed?
    !!params[:month]
  end

  def determine_blog_post_page_number(post)
    return 1 unless post.try(:published?)

    # TODO date doesn't work here
    ids = BlogPost.connection.select_values(base_collection_scope.recent.select(:id).to_sql)
    ids.index(post.id) / E9::Config[:blog_pagination_records] + 1
  end

  def should_group_by_date?
    false # !parent.nil? && E9::Config[:blog_submenu] == 'archive'
  end

  def determine_blog_title
    @blog_title ||= parent.respond_to?(:title) && parent.title || find_current_page.respond_to?(:title) && find_current_page.title || 'Blog'
  end

  def blog_index_page
    @blog_index_page ||= ContentView.find_by_identifier(Page::Identifiers::BLOG_INDEX)
  end

  # this is lifted out of IR, simply the exact method minus scope application
  def end_of_association_chain_before_scopes
    if chain = association_chain.last
      if method_for_association_chain
        chain.send(method_for_association_chain)
      else
        chain
      end
    else
      resource_class
    end
  end
end
