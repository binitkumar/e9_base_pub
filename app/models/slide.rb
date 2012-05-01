class Slide < Page
  include E9::Publishable
  include Hittable
  include Linkable

  has_many :slideshows, :through => :slideshow_assignments, :uniq => true

  mounts_image :image, :spec => 'self.layout.try(:image_spec)', :versions => {
    :embeddable => { :spec => %w(slide_embeddable_width slide_embeddable_height) },
    :thumb      => { :spec => %w(avatar_size avatar_size) },
    :wide_thumb => { :spec => %w(wide_thumb_width wide_thumb_height) }
  }

  ##
  # validations
  #
  validates :body,  :presence => true

  class << self
    def favoritable?; true end
  end

  # TODO modulize this with linkable
  def destroy
    unless soft_links.empty?
      raise ActiveRecord::DeleteRestrictionError.new(self.class.reflections[:soft_links])
    end

    super
  end

  def change_layout(*args)
    super do |_self, _prototype|
      begin
        _self.image.spec = _prototype.image.spec
      rescue
        _self.image.destroy
      end

      _self.published = false
    end
  end

  def to_liquid
    E9::Liquid::Drops::Slide.new(self)
  end

  #
  # hacks around permalink generation.  The @slideshow is set in the controller
  # and if it is, the slide will pass it for polymorphic url args.
  #
  # #permalinked is a method from Linkable that expects you to revert the model
  # back to it's "permalink" polymorphic args and yield it
  #
  # this is a hack written for this purpose.  Currently only slides have multiple
  # links (because of the context of slideshows)
  #

  attr_accessor :slideshow

  def permalinked
    @slideshow, stored = nil, @slideshow
    yield(self)
    @slideshow = stored
  end

  def to_polymorphic_args
    # NOTE if the @slideshow instance variable is set we'll get the slideshow url for this
    # slide, otherwise we'll just get the slides index url
    # [@slideshow || Slide, { :anchor => self }].compact

    if @slideshow
      [@slideshow, { :anchor => self }].compact
    else
      self
    end
  end

  def _post_to_twitter?;  E9::Config[:twitter_slides_by_default] end
  def _post_to_facebook?; E9::Config[:facebook_slides_by_default] end

  def assign_default_preferences
    super

    self.allow_comments           = E9::Config[:slide_allow_comments]        if self.allow_comments.nil?
    self.display_actions          = E9::Config[:slide_display_actions]       if self.display_actions.nil?
    self.display_author_info      = E9::Config[:slide_show_author_info]      if self.display_author_info.nil?
    self.display_date             = E9::Config[:slide_show_date]             if self.display_date.nil?
    self.display_labels           = E9::Config[:slide_show_labels]           if self.display_labels.nil?
    self.display_more_info        = E9::Config[:slide_display_more_info]     if self.display_more_info.nil?
    self.display_social_bookmarks = E9::Config[:slide_show_social_bookmarks] if self.display_social_bookmarks.nil?
  end
end
