class FaqsController < ApplicationController
  include PublicFacingController
  inherit_resources
  filter_access_to_content
  has_role_scope :exact => true
  add_resource_breadcrumbs

  before_filter :collection, :only => :show

  protected

  def add_index_breadcrumb
    add_breadcrumb find_current_page.title, :faqs_path
  end

  def find_current_page
    # hack here because permalink in db doesn't include initial '/'
    @current_page ||= SystemPage.find_by_permalink(request.path.sub(/^\//, '')) || SystemPage.find_by_identifier(Page::Identifiers::FAQ)
  end

  def collection
    @faqs ||= end_of_association_chain.questioned.ordered.includes(:questions).all
  end

  def resource_for_auth
    if params[:id]
      resource
    elsif params[:role]
      Faq.new(:role => params[:role])
    else
      build_resource
    end
  end
end
