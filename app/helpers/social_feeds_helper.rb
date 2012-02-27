module SocialFeedsHelper
  def any_social_feeds_configured?
    twitter_configured? || facebook_configured?
  end

  def twitter_configured?
    @_twitter_configured  ||= E9::Config.instance.twitter_configured?
  end

  def facebook_configured?
    @_facebook_configured ||= E9::Config.instance.facebook_configured?
  end

  def should_show_social_feeds_form_for?(resource)
    [:role, :_post_to_twitter?, :_post_to_facebook?].all? {|m| resource.respond_to?(m) } &&
      E9::Roles.public.includes?(resource.role) && 
      ( !resource.respond_to?(:published?) || resource.published? ) &&
      ( resource._post_to_twitter? && twitter_configured? || resource._post_to_facebook? && facebook_configured? )
  end

  def social_feed_link(record)
    if should_show_social_feeds_form_for?(record)
      render 'shared/social/link', :resource => record
    end
  end
end
