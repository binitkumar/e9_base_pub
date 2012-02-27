class ContentViewsController < InheritedResources::Base
  respond_to :rss
  actions :index
  include Orderable

  skip_js_skippable_filters

  has_scope :for_roles, :default => 'default' do |controller, scope, value|
    scope.for_roles ['user'.role, controller.send(:current_user).role].max.roles
  end

  has_scope :tagged_with, :type => :array do |controller, scope, value|
    any = controller.params[:any] == 'false' ? false : true
    scope.tagged_with(value, :any => any, :show_all => true)
  end

  has_scope :tagged_with_context
  has_scope :of_type, :as => :content_type, :type => :array
  has_scope :of_blog, :type => :array
  has_scope :of_forum, :type => :array
  has_scope :of_slideshow, :type => :array
  has_scope :of_faq, :type => :array
  has_scope :of_parent
  has_scope :top
  
  protected

  def collection
    @content_views ||= end_of_association_chain.feedable.paginate(pagination_parameters)
  end

  def default_ordered_on
    'published_at'
  end

  def default_ordered_dir
    'DESC'
  end
end
