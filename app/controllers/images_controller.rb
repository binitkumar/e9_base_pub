class ImagesController < InheritedResources::Base
  include E9Tags::Controller
  include E9::Controllers::Orderable
  include E9::DestroyRestricted::Controller

  skip_js_skippable_filters :only => [:create, :update]
  skip_after_filter :flash_to_headers, :only => [:create, :update, :select]

  before_filter :determine_index_title, :only => :index
  before_filter '@tag_instructions_scope = :"e9.images"'

  filter_access_to :index, :select, :context => :admin, :require => :read

  has_scope :attached, :only => [:index, :select], :type => :boolean, :default => true
  has_scope :search, :only => [:index, :select]
  has_scope :untagged, :type => :boolean

  has_scope :tagged, :only => [:select, :index], :type => :array, :default => %w(none) do |controller, scope, value|
    if value == %w(none)
      if controller.params[:action] == 'select' && !E9.true_value?(controller.params[:untagged])
        scope.where('1=0')
      else
        scope
      end
    else
      scope.tagged_with(value, :any => false, :show_hidden => true)
    end
  end

  respond_to :json
  respond_to :js, :only => [:index, :select, :destroy, :update]

  def select
    render_404 and return false unless request.xhr?
  end

  def edit
    render_404 and return false unless request.xhr?
  end

  def update
    update! { collection_path }
  end

  protected

    def determine_index_title
      @index_title = 'Images'.tap do |t|
        if params[:search]
          t << " matching \"#{params[:search]}\""
        end

        if params[:tagged]
          t << " tagged #{params[:tagged].map {|t| "\"#{t}\"" }.join(" and ")}"
        elsif E9.true_value?(params[:untagged])
          t.sub! /^/, 'Untagged '
        end
      end
    end

    def find_current_page
      @current_page ||= ContentView.find_by_identifier(Page::Identifiers::ADMIN)
    end

    def collection
      get_collection_ivar || begin
        objects = end_of_association_chain
        objects = objects.paginate(pagination_parameters) if params[:action] == 'index'

        set_collection_ivar objects
      end
    end

end
