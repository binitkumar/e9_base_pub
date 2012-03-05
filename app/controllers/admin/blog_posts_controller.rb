class Admin::BlogPostsController < Admin::PagesController
  include E9::Controllers::View

  add_resource_breadcrumbs

  has_scope :of_blog, :as => :scope, :default => '', :only => :index

  # NOTE for legacy reasons blog_posts is not a direct child of blog, BUT
  # blog is now required, if it is not found, the default blog is chosen
  before_filter :set_new_title, :only => [:new, :create]

  protected

  def page_update_redirect
    admin_blog_posts_path(:scope => resource.blog.id)
  end

  def page_create_redirect
    admin_blog_posts_path(:scope => resource.blog.id)
  end

  def params_for_build
    params[resource_instance_name] ||= {}
    params[resource_instance_name][:user_id] ||= current_user.id

    # NOTE not ||=, this finds the blog given by blog_id, or the default
    # blog, then sets blog_id (effectively doing nothing if it was passed correctly)
    params[resource_instance_name][:blog_id] = find_blog.id
    params[resource_instance_name]
  end

  ##
  # Filters
  #
  def find_layout
    @layout ||= begin
      find_blog && @blog.layout || Layout.for(Blog)
    end
  end

  def find_blog
    @blog ||= begin
      id = params[resource_instance_name].kind_of?(Hash) && params[resource_instance_name][:blog_id]
      id && Blog.find_by_id(id) || Blog.first
    end
  end

  def set_new_title
    @new_title = "Add Blog Post to #{find_blog.title}"
  end
end
