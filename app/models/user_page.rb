class UserPage < Page
  include E9::Publishable
  include Hittable
  include Linkable

  mounts_image :thumb
  def fallback_thumb; E9::Config.instance.try(:user_page_thumb) end

  ##
  # validations
  #
  validates :body, :presence => true

  class << self
    def favoritable?; true end

    def permalink_exists?(permalink)
      super || Campaign.exists?(:code => permalink)
    end
  end

  def destroy
    unless soft_links.empty?
      raise ActiveRecord::DeleteRestrictionError.new(self.class.reflections[:soft_links])
    end

    super
  end

  def copy
    super.tap do |copied| 
      if thumb.present?
        copied.thumb_image_id = Image.create(:file => thumb).id
      end
    end
  end

  def to_polymorphic_args
    self.becomes(Page)
  end

  def _post_to_twitter?;  E9::Config[:twitter_pages_by_default] end
  def _post_to_facebook?; E9::Config[:facebook_pages_by_default] end

  def assign_default_preferences
    super

    self.display_social_bookmarks = E9::Config[:page_show_social_bookmarks] if self.display_social_bookmarks.nil?
    self.display_actions          = E9::Config[:page_display_actions]       if self.display_actions.nil?
    self.display_date             = E9::Config[:page_show_date]             if self.display_date.nil?
    self.display_author_info      = E9::Config[:page_show_author_info]      if self.display_author_info.nil?
    self.display_labels           = E9::Config[:page_show_labels]           if self.display_labels.nil?
    self.allow_comments           = E9::Config[:page_allow_comments]        if self.allow_comments.nil?
  end
end
