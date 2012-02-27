class ForumsController < ApplicationController
  include PublicFacingController
  inherit_resources

  filter_access_to_content :public_readable => true
  add_resource_breadcrumbs

  protected

  def add_index_breadcrumb
    add_breadcrumb forum_index_page.title, forums_path
  end

  def add_show_breadcrumb
    add_breadcrumb! e9_t(:show_title, :title => resource.title)
  end

  def pagination_per_page_default
    E9::Config[:forum_pagination_records]
  end

  def find_current_page
    #@current_page ||= params[:id] ? resource : forum_index_page
    @current_page ||= forum_index_page
  end

  def forum_index_page
    @_forum_index_page ||= ContentView.find_by_identifier(Page::Identifiers::FORUM_INDEX)
  end

  def collection
    @forums ||= end_of_association_chain.for_roleable(current_user_or_public_role).ordered
  end
end
