module Admin::BlogPostsHelper
  def available_blog_select_options
    Blog.where(:role => current_user.roles).map {|blog| [blog.title, blog.id] }.unshift([e9_t(:blog_select_text), nil])
  end

  def blog_post_scope_select_options
    Blog.order(:title).map {|blog| [blog.title, blog.id] }.unshift([e9_t(:all_blog_posts_scope), nil])
  end

  def blog_post_scope_select(blog_id)
    select_tag(:scope, options_for_select(blog_post_scope_select_options, blog_id ? blog_id.to_i : nil))
  end
end
