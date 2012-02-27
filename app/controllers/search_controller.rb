class SearchController < ApplicationController
  include PublicFacingController

  DEFAULT_PER_PAGE = 5

  respond_to :html, :rss

  before_filter :find_or_create_search, :process_results, :add_index_breadcrumb

  filter_access_to :show, :context => :admin

  def index
    if @search
      render :show
    else
      redirect_to :root
    end
  end

  protected

  def add_index_breadcrumb
    add_breadcrumb! e9_t(:index_title, :scope => :search)
  end

  def find_current_page
    @current_page = ContentView.find_by_identifier(Page::Identifiers::SEARCH)
  end

  def pagination_per_page_default
    per_page = E9::Config[:search_records_per_page]
    per_page.blank? || per_page == 0 ? DEFAULT_PER_PAGE : per_page
  end

  def find_or_create_search
    @search = if search_id = params[:id]
      Search.find(search_id)
    elsif params[:query]
      Search.create(search_params)
    else
      flash[:alert] = e9_t(:search_error)
      raise Error, flash[:alert]
    end
  rescue => e
    redirect_to :root and return false
  end

  def process_results
    if @search
      @results = @search.search(params[:search_type]).map do |klass, result| 
        [klass, result.paginate(pagination_parameters)]
      end
    end
  end

  def search_params
    {}.tap do |search_params|
      search_params[:query]       = params[:query]
      search_params[:user]        = current_user
      search_params[:search_type] = params[:search_type]

      search_params[:role]        = [current_user.role, 'user'.role].max
    end
  end
end
