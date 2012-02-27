module SocialFeeds
  extend ActiveSupport::Concern

  FACEBOOK_COMMENT_MAX_LENGTH = 1000
  TWITTER_COMMENT_MAX_LENGTH  = 115
  
  included do 
    validates  :twitter_forum_template,     :liquid => true, :length => { :maximum => TWITTER_COMMENT_MAX_LENGTH  }
    validates  :twitter_page_template,      :liquid => true, :length => { :maximum => TWITTER_COMMENT_MAX_LENGTH  }
    validates  :facebook_forum_template,    :liquid => true, :length => { :maximum => FACEBOOK_COMMENT_MAX_LENGTH }
    validates  :facebook_page_template,     :liquid => true, :length => { :maximum => FACEBOOK_COMMENT_MAX_LENGTH }
    validates  :facebook_company_page_url,  :link => { :external_only => true, :allow_blank => true } 
  end

  FACEBOOK_AUTH_FIELDS = %w(facebook_app_secret facebook_app_id)

  def facebook_auth_ready?
    !FACEBOOK_AUTH_FIELDS.any? {|attr_name| send(attr_name).blank? }
  end

  FACEBOOK_REQUIRED_FIELDS = %w(facebook_access_token)

  def facebook_configured?
    FACEBOOK_REQUIRED_FIELDS.all? {|field| send(field).present? }
  end

  TWITTER_REQUIRED_FIELDS = %w(twitter_app_id twitter_app_secret twitter_access_token twitter_secret_token)

  def twitter_configured?
    TWITTER_REQUIRED_FIELDS.all? {|field| send(field).present? }
  end
end
