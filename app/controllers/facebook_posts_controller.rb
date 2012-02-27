class FacebookPostsController < ApplicationController
  before_filter :authenticate_user!
  skip_js_skippable_filters

  layout false

  respond_to :html, :only => :new
  respond_to :js

  def new
    @facebook_post = FacebookPost.new

    respond_to do |format| 
      format.html
      format.js
    end
  end

  def create
    @facebook_post = build_resource

    if @facebook_post.errors.empty?
      @facebook_post = @facebook_post.fetch
    end

    respond_with(@facebook_post) do |format|
      format.js
    end
  end

  def destroy
    @facebook_post = resource
    @facebook_post.destroy

    respond_with(@facebook_post) do |format|
      format.js
    end
  end

  protected

  def collection
    @facebook_posts ||= FacebookPost.all(params.slice(:limit, :until, :since))
  end
  helper_method :collection

  def resource
    @facebook_post ||= FacebookPost.find(params[:id]) if params[:id]
  rescue FbGraph::NotFound => e
    Rails.logger.error(e.message)
  end
  helper_method :resource

  def build_resource
    @facebook_post ||= FacebookPost.create(params[:facebook_post])
  end
end
