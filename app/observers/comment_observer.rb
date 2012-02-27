class CommentObserver < ActiveRecord::Observer
  def after_create(comment)
    recipients, commentable = [], comment.commentable

    # collect "favoriters"
    if commentable.respond_to?(:favoriters)
      recipients |= commentable.favoriters.for_roles(commentable.role.self_and_included_by)
    end

    # collect "commenters"
    if commentable.respond_to?(:commenters)
      recipients |= commentable.commenters.for_roles(commentable.role.self_and_included_by)
    end

    # add original commentable author
    recipients << commentable.try(:author)

    # don't send to the author of the comment
    recipients.delete comment.try(:author)

    recipients.uniq!
    recipients.compact!

    # if there are any, send to the comment_updates list
    unless recipients.empty?
      SystemEmail.comment_update.send! :page       => comment, 
                                       :sender     => comment.try(:author), 
                                       :recipients => recipients.map(&:id)
    end
  end
end
