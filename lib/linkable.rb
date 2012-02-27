module Linkable
  extend ActiveSupport::Concern

  #
  # Linkable can be given default_url_options on each request, which can be used for it's includees to
  # generate URLs based on request without needing dependency injection
  #
  # e.g. in ApplicationController:
  #
  # before_filter {|controller| Linkable.default_url_options = controller.url_options }
  #
  mattr_accessor :default_url_options
  @@default_url_options = {:host => 'www.example.com', :protocol => 'http://'}

  def Linkable.urlify_path(path, options = {})
    options.reverse_merge!(default_url_options)

    path ||= ''

    if path =~ /^https?:\/\/(.*)/i
      "#{options[:protocol]}#{$1}"
    else
      "#{options[:protocol]}#{options[:host]}/#{path.sub(/^\//, '')}"
    end
  end

  # NOTE gsub on an html_safe string results in nil matches ($1 et al)
  def Linkable.urlify_html(html)
    html.gsub(/(<a[^>]+href[= ]+["'])([^'"]{0,})(['"])/) do
      a, path, b = $1, $2, $3
      "#{a}#{urlify_path(path)}#{b}"
    end
  end

  # block to temporarily reset Linkable.default_url_options
  # (for sending mail and maintaining the current options, mainly.)
  #
  # Without a doubt entirely unnecessary!
  #
  def Linkable.with_default_url_options(temp_options, &block)
    temp_options.reverse_merge! @@default_url_options

    stored_options, @@default_url_options = @@default_url_options, temp_options
    yield
  ensure
    @@default_url_options = stored_options
  end

  included do
    include Rails.application.routes.url_helpers
    include E9::Helpers::Urls

    if self.menu_linkable?
      has_one  :link, :as => :linkable, :dependent => :destroy
      has_many :soft_links, :through => :link, :dependent => :restrict

      after_create :create_associated_link

      # force updated_at on menus to change, which gives them a new cache_key
      after_save :touch_associated_soft_links
    end
  end

  module ClassMethods

    # If menu_linkable? is set to false in a class it's members will not be included in the list
    # of eligible links in the admin.  It does not prevent them from being added manually, however.
    unless respond_to?(:menu_linkable?)
      def menu_linkable?; true end
    end

    # retrieve url options directly from Linkable
    def default_url_options
      Linkable.default_url_options
    end
  end

  unless instance_methods.map(&:to_sym).include?(:to_polymorphic_args)
    #
    # Linkable must override this to let rails know the objects that should determine its routing
    # 
    # should return arguments expected by url_for which represent its location, typically a
    # hierarchical chain of parents representing nested resources, e.g. [forum, topic, comment] or
    # simply a string representing a hardcoded path
    #
    # probably most this will be:
    # def to_polymorphic_args; self end
    #
    # NOTE See below for a hack for polymorphic_url below that allows passing options to polymorphic_url through link to,
    # e.g. link_to "somewhere", [forum, topic, { :anchor => "comment_#{comment.id}" }]
    #
    def to_polymorphic_args
      raise NotImplementedError
    end
  end

  def url(options = {})
    return '' if new_record?

    pargs = to_polymorphic_args
    return Linkable.urlify_path(pargs) if pargs.is_a?(String)

    polymorphic_url(pargs, options)
  end

  def path(options = {})
    return '' if new_record?

    pargs = to_polymorphic_args
    return pargs if pargs.is_a?(String)

    polymorphic_path(pargs, options)
  end

  def touch_associated_soft_links
    # touch any soft links and all ancestors they may have in menus
    ancestral_ids = self.soft_links.map(&:self_and_ancestors).flatten.map(&:id)

    unless ancestral_ids.blank?
      Menu.update_all ["updated_at = ?", DateTime.now], ["id in (?)", ancestral_ids]
    end
  end

  def create_associated_link
    self.create_link(:linkable => self)
  end

  # "permalinked" is a solution to certain models (Slide) having different links
  # based on context (Slideshows).  This method is overridden to provide a way
  # for a model to revert itself to its true "permalink" then reset its context.
  #
  # e.g.
  #
  # def permalinked
  #   clear_context()
  #   yield
  #   restore_context()
  # end
  #
  def permalinked
    yield(self)
  end

  protected :touch_associated_soft_links, :create_associated_link
end
