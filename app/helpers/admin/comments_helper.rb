module Admin::CommentsHelper
  def flagged?
    params[:action] == 'flagged'
  end

  def render_admin_comments(comments)
    render :partial => 'comments/comment', :collection => comments, :locals => { :remove_on_unflag => flagged?, :hide_avatar => true, :show_title => true }
  end

  def delete_all_user_comments_link(user)
    link_to e9_t(:delete_all_comments_link), delete_all_admin_user_comments_path(user), :confirm => e9_t(:confirmation_question), :method => :put, :remote => true
  end

  def admin_comments_title_helper(count)
    title admin_comments_title, :id => :admin_comments_title, :insert => flagged_comments_count_tag(count)
  end

  def flagged_comments_count_tag(count = nil)
    content_tag :span, "(#{count || Flag.comments.count})", :id => 'flagged-comments-count'
  end
end
