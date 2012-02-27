module FacebookPostsHelper
  def facebook_pagination_link(opts = {})
    link_to("Show More", facebook_posts_path(opts), :remote => true) unless opts.blank?
  end

  def facebook_posts_delete_link(facebook_post)
    link_to(e9_t(:delete_link), facebook_post_path(facebook_post.identifier), {
      :class => 'delete', 
      :method => :delete, 
      :confirm => e9_t(:confirmation_question), 
      :remote => true
    })
  end
end
