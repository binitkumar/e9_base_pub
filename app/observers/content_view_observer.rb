class ContentViewObserver < ActiveRecord::Observer

  def publish_content(record)
    return true unless observer_enabled?

    ##
    # broadcast social (only topics)
    # 
    if record.is_a?(Topic)
      if E9::Roles.public.includes?(record.role)
        if E9::Config.instance.facebook_configured? && record._post_to_facebook?
          FacebookPost.asynchronous_create(record.generate_facebook_argument_hash)
        end

        if E9::Config.instance.twitter_configured? && record._post_to_twitter?
          TwitterStatus.asynchronous_create(record.generate_twitter_argument_hash)
        end
      end
    end

    ##
    # send new content email
    #
    args = {:page => record}

    if author = record.try(:author)
      args[:sender] = author
      args[:excluding] = author.try(:id)
    end

    SystemEmail.new_content_alert.send!(args)
  end
end
