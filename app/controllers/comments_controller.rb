class CommentsController < InheritedResources::Base
  include E9::Controllers::Recaptcha

  belongs_to :content_view, :optional => true, :finder => :find_by_permalink!
  respond_to :js, :xml

  has_scope :on_type, :only => :index
  has_scope :by_user, :only => :index
  has_scope :by_user_distinct_on_commentable, :only => :index

  before_filter :authenticate_user!
  prepend_before_filter :check_honeypot, :only => :create

  def create
    create! do |format|
      format.js do 
        if @comment.errors.any?
          flash[:alert] = @comment.errors.full_messages.first
        end

        render
      end
    end
  end

  protected

  def destroy_resource(comment)
    comment.delete!(:deleter => current_user)
  end

  def pagination_per_page_default
    E9::Config[:my_home_records]
  end

  ##
  # IR
  #
  def collection
    @comments ||= begin
      @comments_count = end_of_association_chain.count
      end_of_association_chain.recent.includes(:commentable).paginate(pagination_parameters.merge(:total_entries => @comments_count))
    end
  end

  ##
  # CMS
  #
  def find_current_page
    @current_page = ContentView.find_by_identifier(Page::Identifiers::FORUM_INDEX)
  end

  ##
  # Filters
  # 
  # TODO modulize honeypot
  #
  def check_honeypot
    unless params[:comment].delete(:email).blank?
      flash[:notice] = I18n.t(:notice, :scope => :"flash.actions.create", :resource_name => 'Comment')
      respond_with(build_resource) do |format|
        format.js { head :ok }
      end
    end
  end

  def build_resource
    @comment ||= begin
      end_of_association_chain.new(build_params)
    end
  end

  def build_params
    (params[:comment] || {}).merge(:user_id => current_user.id)
  end
end
