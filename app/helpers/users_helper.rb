module UsersHelper

  # helper to figure out which form should get the @user object on the signin/signup page
  def sign_in_or_sign_up?
    case params[:controller]
    when /registration/ then :sign_up
    when /session/ then :sign_in
    end
  end

  def initial_comments
    Comment.by_user_distinct_on_commentable(current_user).tap {|scope|
      @comments_count = scope.count
    }.includes(:commentable).paginate(:page => 1, :per_page => pagination_per_page, :total_entries => @comments_count)
  end

  def render_profile_comments(comments)
    comments.map do |comment|
      commentable = comment.commentable
      render "#{commentable.class.model_name.collection}/listing", :listing => commentable
    end.join.html_safe
  end

  def show_more_profile_comments_link(wp_results)
    if !wp_results.empty? && wp_results.next_page
      count = [wp_results.per_page, wp_results.total_entries - wp_results.current_page * wp_results.per_page].min

      link_to(e9_t(:show_more_link, :count => count),
              comments_path(:page => wp_results.next_page, :by_user_distinct_on_commentable => current_user.id), 
              :remote => true, 
              :id => "show-more-commented-link")
    end
  end

  def sign_in_auth_failure?
    flash[:alert] == I18n.t(:invalid, :scope => :"devise.failure")
  end

  def user_info(user)
    [user.name, user.email, user.username].compact.map {|val| val }.join("<br/>").html_safe
  end

end
