module TopicsHelper
  def forum_select_array
    @_forum_select_array ||= begin
      Forum
        .for_roleable(current_user)
        .order(:title)
        .map {|f| [f.title, f.id] }
        .unshift( [ e9_t(:no_choice_select_option, :element => Forum.model_name.element.titleize), nil ])
    end
  end
  
  def topics_title_helper(topic)
    title topic.title, :id => 'topic-title', :insert => comments_count_tag(topic)
  end

  def topic_last_reply_byline(topic, options = {})
    if comment = topic.comments.last

      content_tag(:div, :class => 'last-reply-byline') do
        e9_t :last_reply_byline,
             :at       => localize(comment.created_at, :format => :dateline),
             :email    => comment.author.try(:email) || e9_t(:no_author_name),
             :username => comment.author.try(:username) || e9_t(:no_author_name), 
             :name     => comment.author.try(:name) || e9_t(:no_author_name)
      end.html_safe
    end
  end
end
