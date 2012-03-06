class AttachmentsController < InheritedResources::Base
  include E9Tags::Controller
  include E9::Controllers::Orderable

  before_filter :determine_index_title, :only => :index
  before_filter '@tag_instructions_scope = :"e9.attachments"'

  skip_js_skippable_filters :only => [:create, :update]
  skip_after_filter :flash_to_headers, :only => [:create, :update]

  has_scope :attached, :only => [:index], :type => :boolean, :default => true
  has_scope :search, :only => [:index]
  has_scope :untagged, :type => :boolean

  has_scope :tagged, :only => [:index], :type => :array do |controller, scope, value|
    scope.tagged_with(value, :any => false, :show_hidden => true)
  end

  def edit
    render_404 and return false unless request.xhr?
  end

  def update
    update! { collection_path }
  end

  respond_to :json
  respond_to :js, :only => [:index, :select, :destroy, :update]

  protected

    def determine_index_title
      @index_title = 'Files'.tap do |t|
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
