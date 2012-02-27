class Admin::PagesController < Admin::ContentController
  # NOTE this name is legacy, should be "content_views" controller
  respond_to :html, :js

  include E9::Controllers::Orderable
  include E9Tags::Controller
  include E9::Social::Controller

  skip_js_skippable_filters :only => [:layouts, :change_layout, :publish, :unpublish]
  prepend_before_filter :delete_scope_if_blank

  filter_access_to :layouts, :change_layout, :attribute_check => true, :load_method => :filter_target, :context => :admin

  use_tiny_mce :except => [:index, :destroy]

  def create
    create! do |s, f|
      s.html { redirect_to page_create_redirect }
      s.js { render page_create_render  }
      f.js { render page_create_render  }
    end
  end

  def update
    update! do |s, f|
      s.html { redirect_to page_update_redirect }
      s.js { render page_update_render  }
      f.js { render page_update_render  }
    end
  end

  def destroy
    destroy! do |format|
      format.html { redirect_to_back_or(parent_index) }
      format.js do 
        path = polymorphic_path([:admin, resource_class])
        path = session[:return_to] if Regexp.new(path) =~ session[:return_to]
        head :status => 204, :location => path
      end
    end
  end

  def publish
    object = resource
    object.published = true
    object.save

    respond_with(object) do |format|
      format.html { redirect_to(page_update_redirect) }
      format.js { render shared_template('toggle_published') }
    end
  end

  def unpublish
    object = resource
    object.published = false
    object.save

    respond_with(object) do |format|
      format.html { redirect_to(page_update_redirect) }
      format.js { render shared_template('toggle_published') }
    end
  end

  protected

  def row_partial
    'row'
  end

  helper_method :row_partial

  ##
  # IR
  #

  def page_update_render
    shared_template('update')
  end

  def page_create_render
    shared_template('create')
  end

  def page_update_redirect
    back_or_default_path(parent_index)
  end

  def page_create_redirect
    parent_index
  end

  helper_method :page_update_redirect, :page_create_redirect, :page_update_render, :page_create_render

  def resource
    get_resource_ivar || set_resource_ivar(end_of_association_chain.find_by_permalink!(params[:id]))
  end

  def collection
    get_collection_ivar || set_collection_ivar( end_of_association_chain.paginate(pagination_parameters) )
  end

  def parent_index
    polymorphic_path([:admin, resource_class])
  end

  def delete_scope_if_blank
    params.delete(:scope) if params[:scope].blank?
  end

  ##
  # Orderable
  #
  def default_ordered_dir
    'desc'
  end

  def default_ordered_on
    'published_at'
  end


  SHARED_TEMPLATE_DIR = 'admin/views'

  def shared_template(file)
    File.join(SHARED_TEMPLATE_DIR, file.to_s)
  end

  helper_method :shared_template

end
