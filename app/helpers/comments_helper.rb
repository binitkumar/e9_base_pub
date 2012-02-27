module CommentsHelper
  def delete_comment_link(comment, namespace = nil)
    link_to e9_t(:delete_comment_link),
            [namespace, comment],
            :remote => true, 
            :method => :delete, 
            :confirm => e9_t(:confirmation_question),
            :class => 'action-link delete-comment'
  end

  def comments_count_tag(commentable)
    content_tag :span, "(#{comments_count(commentable)})", :id => 'comments-count'
  end

  def comments_count_link(commentable, options = {})
    key = options.delete(:show_count) ? :link_text : :link_text_no_count

    link_text = e9_t(key, :scope => :comments, :count => comments_count(commentable))

    if options[:text_only]
      return content_tag(:span, link_text, :class => 'comments-link')
    end

    link_args = []

    if commentable.respond_to?(:to_polymorphic_args)

      # see Linkable for permalinked explanation
      commentable.permalinked do |c|
        link_args << c.to_polymorphic_args
      end
    end

    hash_arg = link_args.last.is_a?(Hash) ? link_args.pop : {}
    hash_arg[:anchor] = :comments
    link_args << hash_arg

    link_to link_text, polymorphic_path(*link_args), :class => 'action-link comments-link'
  end

  def comments_count(commentable)
    @_comments_count ||= {}
    @_comments_count[commentable.hash] ||= commentable.reload.comments_count
  end

  def comment_link(comment)
    unless comment.commentable.blank?
      link_to comment.commentable.title, comment.commentable.url
    end
  end

  def comment_deleter(comment)
    # if the author is the deleter, call it User... otherwise deleter was admin
    comment.author == comment.deleter ? 'User' : 'Administrator'
  end

  def comment_body_escape(body)
    sanitize auto_link(simple_format(body), :html => { :rel => 'external nofollow' }, :link => :urls)
  end
end
