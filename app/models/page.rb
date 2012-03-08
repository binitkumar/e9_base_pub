class Page < ContentView
  module Identifiers
    ADMIN                = 'admin'
    ADMIN_HELP           = 'admin_help'
    BLOG_INDEX           = 'blog'
    EDIT_PROFILE         = 'edit_profile'
    EVENTS               = 'events'
    FAQ                  = 'faqs'
    FORUM_INDEX          = 'forums'
    HOME                 = 'home'
    NOT_FOUND            = 'not_found'
    PASSWORDS            = 'passwords'
    PROFILE              = 'profile'
    REVOKE               = 'revoke'
    SEARCH               = 'search'
    SIGN_IN              = 'sign_in'
    SIGN_UP              = 'sign_up'
    SLIDES               = 'slides'
    SLIDESHOWS           = 'slideshows'
    SYSTEM_MASTER        = 'system_master'
    UNSUBSCRIBE          = 'unsubscribe'
    USERS                = 'users'
  end

  class << self
    def not_found
      find_by_identifier(Identifiers::NOT_FOUND)
    end

    def search_results
      find_by_identifier(Identifiers::SEARCH_RESULTS)
    end

    def blog_index
      find_by_identifier(Identifiers::BLOG_INDEX)
    end

    def forum_index
      find_by_identifier(Identifiers::FORUM_INDEX)
    end

    def slides_index
      find_by_identifier(Identifiers::SLIDES)
    end

    def slideshows_index
      find_by_identifier(Identifiers::SLIDESHOWS)
    end

    def faq_index
      find_by_identifier(Identifiers::FAQ)
    end
  end

  module Status
    PUBLISHED = 'Published'
    DRAFT     = 'Draft'
  end

  ##
  # validations
  #
  validates :title,         :length    => { :maximum => 255 }
  validates :published_at,  :presence  => true

  ##
  # callbacks
  #
  before_save :prepare_text_version
  after_save  :publish_if_should_publish!

  ##
  # scopes
  #
  scope :search, lambda {|*args|
    opts = args.extract_options!
    term = args.shift

    if term.blank?
      where("1=0")
    else
      find_scope = scoped.published
      conditions = any_attrs_like_scope_conditions(:text_version, :title, term, opts)
      
      if opts[:roles] 
        find_scope = find_scope.where(:role => opts.delete(:roles))
      end

      find_scope.where(conditions).
          union_of(find_scope.tagged_with(term)).order('published_at DESC')
    end
  }

  ##
  # instance methods
  #
  def to_param
    (permalink || '').parameterize
  end

  # menu ancestors used for dynamic breadcrumb generation
  # 
  # NOTE only user pages use dynamic breadcrumbing.  System pages have controller defined breadcrumbs.
  def menu_ancestors
    # NOTE Root level menus are not links, shift it off.  "Home" crumb is handled in app controller
    @menu_ancestors ||= (master_menu.try(:ancestors) || []).tap {|m| m.shift }
  end

  # basically only SystemPages have controller rendered breadcrumbs
  def has_own_breadcrumbs?
    !self.is_a?(SystemPage)
  end

  def master_menu
    @master_menu ||= soft_links.detect {|m| m.root.master? }
  end

  def to_liquid
    E9::Liquid::Drops::Page.new(self)
  end

  def _facebook_template; E9::Config[:facebook_page_template] end
  def _twitter_template;  E9::Config[:twitter_page_template]  end

end
