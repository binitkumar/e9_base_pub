class E9Crm::ResourcesController < E9Crm::BaseController
  inherit_resources

  include E9::Helpers::ResourceErrorMessages
  include E9::Controllers::InheritableViews

  # NOTE depending on e9_base pagination (which should eventually use this module)
  #include E9::Helpers::Pagination
  include E9::DestroyRestricted::Controller

  # TODO implement role on e9_crm models?
  #include E9::Roles::Controller
  #filter_access_to :update, :edit, :attribute_check => true, :load_method => :filter_target, :context => :admin

  class_inheritable_accessor :should_paginate_index
  self.should_paginate_index = true

  respond_to :js

  add_resource_breadcrumbs

  def self.defaults(hash = {})
    super(hash.reverse_merge(:route_prefix => nil))
  end

  def create
    create! { collection_path }
  end

  def update
    update! { collection_path }
  end

  protected

  def should_paginate_index
    self.class.should_paginate_index
  end

  def filter_target
    resource
  end

  # NOTE parent is defined so it's always available, it will be overridden on controllers which have belongs_to routes
  def parent; end
  helper_method :parent

  def add_index_breadcrumb
    yield if block_given?
    association_chain # to ensure parent is available
    add_breadcrumb! @index_title || e9_t(:index_title), collection_path
  end

  # expose collection scope to be overridden
  def collection_scope
    end_of_association_chain
  end

  def collection
    get_collection_ivar || begin 
      scope = collection_scope

      if should_paginate_index && request.format != :json
        scope = scope.paginate(pagination_parameters)
      end

      # note decorate is mapped this way rather than using the scope.decorate
      # method because tasks/notes use different decorators
      scope.map!(&:decorate) if scope.respond_to?(:decorate)
      set_collection_ivar scope
    end
  end

  def resource
    get_resource_ivar || begin
      # NOTE it's necessary to set readonly => false here for records
      #      on associations to be editable
      object = end_of_association_chain.send(method_for_find, params[:id], :readonly => false)

      # We want to decorate resources being viewed, not edited... Perhaps default decoration
      # isn't really a good idea in the resource controller?
      #
      # e.g. this caused the problem where tag fields weren't working because the object's
      # class name was incorrect (ResourceDecorator vs Resource).  It was a mistake that caused
      # the error, but still, an insidious bug caused for no reason (as there's no need to decorate
      # resources in forms).
      unless %w(update edit create new).member? params[:action]
        object = object.decorate if object.respond_to?(:decorate)
      end

      set_resource_ivar object
    end
  end

  def default_ordered_on
    'created_at'
  end

  def default_ordered_dir
    'DESC'
  end
end
