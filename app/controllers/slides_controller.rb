class SlidesController < ApplicationController
  include PublicFacingController
  include Orderable

  inherit_resources
  belongs_to :slideshow, :finder => :find_by_permalink!, :optional => true

  respond_to :json, :html

  ##
  # Filters
  #

  # NOTE Pseudo parent is set AFTER association_chain has already frozen the 
  #      lookup (as slide should not be looked for in pseudo parent scope)
  before_filter :association_chain, :set_pseudo_parent_if_applicable

  # page level filtering falls to the slideshow first, the slides if no parent
  filter_access_to :index, :show, :attribute_check => true, :load_method => :filter_target, :context => :pages

  add_resource_breadcrumbs

  ##
  # Scopes
  #

  has_scope :tagged_with_context,          :except => :show
  has_scope :limit,                        :except => :show
  has_scope :tagged_with, :type => :array, :except => :show do |controller, scope, value|
    any = controller.params[:any] == 'false' ? false : true
    scope.tagged_with(value, :any => any)
  end

  ##
  # Actions
  #
  
  def show
    resource.increment_hits!
    respond_with(resource)
  end

  #
  # Index actually finds the collection and loads a slide by ID in context on the slideshow 
  # (or custom search slideshow).  If no id is passed it will look for the first slideshow.
  #
  def index
    index! do |format|
      format.html
      format.json do
        object = if params[:id]
          resource.increment_hits!
          resource
        else
          collection
        end

        render :json => object 
      end
    end
  end

  protected

  ##
  # IR
  #
  def collection 
    @slides ||= begin
      scope = collection_scope

      # NOTE we do the search here because it is NOT a scope (it's a join and sort with tags)
      scope = scope.search(params[:search]) if params[:search].present?

      objects = scope.map {|slide| slide.decorate }

      objects.tap do |slides|
        # NOTE slidemethods is included on collection to allow for methods like page, position, etc
        class << slides
          include Slideshow::SlideMethods
        end
      end
    end
  end

  def collection_scope
    end_of_association_chain.for_role(current_user_or_public_role).published
  end

  # we use resource in slideshow to determine the current slide. This creates an issue 
  # because slide permalinks should behave like other resources if they are above a user's 
  # role or not published (unauthorized or "currently unavailable" messages).  In a slideshow
  # on the other hand, these resources are excluded from the collection.  Meaning
  # a standalone resource should use a typical scope, but be filtered to the collection
  # scope when accessed in the index action.
  #
  def resource_scope
    index? ? collection_scope : end_of_association_chain
  end

  def resource
    @slide ||= SlideDecorator.decorate(resource_scope.find_by_permalink!(params[:id]))

  rescue ActiveRecord::RecordNotFound
    # in index we want record not found to show the first slide if it exists, otherwise reraise
    raise $! unless index? && first_slide = collection.first

    # finally set the slide to be the first slide in the collection
    @slide = SlideDecorator.decorate(first_slide)
  ensure
    # Slides have a temporary "slideshow" attr that associates them to one slideshow.
    # This is used primarily for determining the current route to the resource,
    # as if slideshow is present the slide will send it as part of it's polymorphic
    # route args, resulting in a slideshow_slide route instead of just slide
    @slide.slideshow = parent if @slide.present? && parent?
  end

  ##
  # resource breadcrumb impl
  #
  def add_index_breadcrumb
    if parent?
      if parent.new_record?
        add_breadcrumb index_title, slides_path(slide_query_params)
      else
        add_breadcrumb index_title, slideshow_path(parent)
      end
    end
  end

  def add_show_breadcrumb
    add_breadcrumb! resource.title
  end

  ##
  # system
  #
  def find_current_page
    @current_page ||= (!index? || request.xhr?) ? resource : Page.slides_index
  end

  # for auth
  def filter_target
    if parent?
      parent
    elsif params[:id].present?
      resource
    else
      Slide.new
    end
  end

  # TODO slide query params should really be inclusive rather than exclusive
  def slide_query_params
    query_params.except(:format, :id, :html)
  end

  ##
  # helpers
  #

  def index_title
    @index_title ||= parent? ? parent.title : find_current_page.title
  end

  #
  # determine the appropriate url for a slide based on the current context
  #
  # when no slideshow            => standalone permalink
  # when slideshow is new_record => within a custom/pseudo slideshow
  # when slideshow persisted     => within an actual slideshow
  #
  # accepts options:
  #   only_path : in the same way as url_for
  #
  def contextual_slide_url(*args)
    options = args.extract_options!
    options.slice!(:only_path, :page, :per_page)

    # change determinant to fix issue with SlideDecorator
    slideshow = args.find {|arg| arg.respond_to?(:slides) }
    slide     = args.find {|arg| arg.respond_to?(:slideshows) }

    if slideshow.blank?
      if slide.present?
        slide_url(slide, options)
      else
        ''
      end
    else
      if slide.present?
        options[:anchor] = slide.to_param
      end

      if slideshow.new_record?
        slides_url options.reverse_merge(slide_query_params)
      else
        slideshow_url slideshow, options
      end
    end
  end

  def contextual_slide_path(*args)
    options = args.extract_options!
    contextual_slide_url(*args, options.merge(:only_path => true))
  end

  def custom_slideshow_title
    @_custom_slideshow_title ||= if custom_slideshow?
      if params[:search]
        e9_t(:search_index_title, :search => params[:search]) else e9_t(:custom_index_title, :search => params[:search])
      end
    end
  end

  helper_method :index_title, :contextual_slide_url, :contextual_slide_path, :custom_slideshow_title

  ##
  # ordered impl
  #
  # ordering should only take place in custom_slideshows (otherwise it's decided by the slideshow)
  #
  def default_ordered_on; 'published_at' end
  def default_ordered_dir; 'DESC' end
  def ordered_if; custom_slideshow? end

  ##
  # NOTE this should be called AFTER association_chain has been called and frozen the lookup
  # (so the controller doesn't look to parent.slides as the scope)
  #
  def set_pseudo_parent_if_applicable
    if custom_slideshow?
      # NOTE inherited_resources default #parent? looks at @parent_type to determine if there is a parent
      @parent_type = :slideshow
      @slideshow   = Slideshow.new(:title => custom_slideshow_title, :pseudo_slides => collection)
    end
  end

  private

  def determine_layout
    if params[:action] == 'show' && slide_layout = Layout.find_by_identifier('slide')
      slide_layout.template
    else
      super
    end
  end

  def index?
    params[:action] == 'index'
  end
  
  def custom_slideshow?
    index? and parent.blank? || parent.new_record?
  end
end
