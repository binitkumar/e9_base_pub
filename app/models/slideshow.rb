class Slideshow < Category

  def thumb
    if slides.present?
      slides.first.thumb
    else
      E9::Config.instance.try(:user_page_thumb)
    end
  end

  def generate_facebook_argument_hash(*args)
    super(*args).merge({
      :link        => url,
      :name        => title,
      :description => description,
      :picture     => Linkable.urlify_path(thumb.url)
    })
  end

  module SlideMethods
    def before(slide, circular = false)
      if i = index {|s| s.id == slide.id }
        if i != 0
          slice(i - 1)
        elsif circular # && i != length - 1
          slice(length - 1)
        end
      end
    end

    def after(slide, circular = false)
      if i = index {|s| s.id == slide.id }
        if i != length - 1
          slice(i + 1)
        elsif circular # && i != 0
          slice(0)
        end
      end
    end

    def position(slide)
      if i = index {|s| s.id == slide.id }
        i + 1
      end
    end

    def page(slide, per_page = E9::Config[:slide_pagination_records])
      if i = index {|s| s.id == slide.id }
        i / per_page + 1
      end
    end

    def page_count(per_page = E9::Config[:slide_pagination_records])
      (count.to_f / per_page).ceil
    end
  end

  ##
  # Slideshow's slide association is called `associated_slides` to differentiate
  # from `pseudo_slides`, as a Slideshows are also used as a collection to maintain 
  # temporary slideshows (search results "view as slideshow")
  #
  has_many :slideshow_assignments, :dependent => :destroy
  has_many :associated_slides, :class_name => 'Slide', :source => 'slide', :through => :slideshow_assignments, :uniq => true, :order => "slideshow_assignments.position" do
    include SlideMethods
  end

  def pseudo_slides
    @pseudo_slides || associated_slides # falls back to associated
  end

  def pseudo_slides?
    @pseudo_slides.nil?
  end

  def pseudo_slides=(relation)
    class << relation
      include SlideMethods
    end

    @pseudo_slides = relation
  end

  delegate :before, :after, :slide_position, :page, :pages, :count, :first, :last, :to => :slides

  def slides
    persisted? ? associated_slides : pseudo_slides
  end

  def to_polymorphic_args
    self
  end

  def to_liquid
    E9::Liquid::Drops::Slideshow.new(self)
  end

  def _facebook_template; E9::Config[:facebook_page_template] end
  def _twitter_template;  E9::Config[:twitter_page_template]  end
  def _post_to_twitter?;  E9::Config[:twitter_slideshows_by_default] end
  def _post_to_facebook?; E9::Config[:facebook_slideshows_by_default] end
end
