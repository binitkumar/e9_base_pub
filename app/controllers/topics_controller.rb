class TopicsController < ApplicationController
  inherit_resources

  respond_to :rss, :only => :index

  belongs_to :forum, :finder => :find_by_permalink!, :optional => true
  prepend_before_filter :association_chain

  include PublicFacingController
  include E9Tags::Controller
  include E9::Controllers::Commentable

  filter_access_to_content :public_readable => true
  add_resource_breadcrumbs

  def show
    resource.increment_hits!
    show!
  end

  def create 
    create! { resource.forum } 
  end

  def destroy 
    destroy! { destroy_redirect } 
  end

  protected

  def pagination_per_page_default
    E9::Config[:forum_pagination_records]
  end

  def params_for_build
    (params[resource_instance_name] || {}).reverse_merge({
      :user_id => current_user.try(:id)
    })
  end

  def resource
    @topic ||= end_of_association_chain.find_by_permalink!(params[:id], :include => { :comments => [:flag, :author] })
  end

  def collection
    @topics ||= end_of_association_chain.order_by(:published_at, :reverse => true).paginate(pagination_parameters)
  end

  def build_resource
    @topic ||= begin
      if parent
        parent.topics.build(params_for_build)
      else
        Topic.new(params_for_build)
      end
    end
  end

  def destroy_redirect
    resource.forum.topics.empty? ? forums_path : resource.forum
  end

  def find_current_page
    @current_page = params[:id] ? resource : parent || forum_index_page
  end

  def forum_index_page
    @_forum_index_page ||= ContentView.find_by_identifier(Page::Identifiers::FORUM_INDEX)
  end

  def add_index_breadcrumb
    add_breadcrumb forum_index_page.title, :forums_path
    add_breadcrumb parent.title, forum_path(parent) if parent
  end

  def add_show_breadcrumb
    add_breadcrumb resource.forum.title, forum_path(resource.forum) unless parent
    add_breadcrumb! e9_t(:show_title, :title => resource.title)
  end

  def add_edit_breadcrumb
    add_breadcrumb resource.forum.title, forum_path(resource.forum) unless parent
    add_breadcrumb! e9_t(:edit_title, :title => resource.title)
  end
end
