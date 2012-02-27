class TwitterStatusesController < ApplicationController
  before_filter :authenticate_user!
  skip_js_skippable_filters

  layout false

  respond_to :html, :only => :new
  respond_to :js

  before_filter :collection, :only => :index
  before_filter :resource,   :only => [:destroy, :show]

  def new
    @twitter_status = TwitterStatus.new

    respond_to do |format| 
      format.html
      format.js
    end
  end

  def create
    @twitter_status = build_resource

    respond_with(@twitter_status) do |format|
      format.js
    end
  end

  def destroy
    @twitter_status = resource
    @twitter_status.destroy

    respond_with(@twitter_status) do |format|
      format.js
    end
  end

  protected

  def pagination_per_page_default
    E9::Config[:feed_records]
  end

  def resource
    @twitter_status ||= TwitterStatus.find(params[:id]) if params[:id]
  end
  helper_method :resource

  def build_resource
    @twitter_status ||= TwitterStatus.create(params[:twitter_status])
  end
  helper_method :build_resource

  def collection
    @twitter_statuses ||= TwitterStatus.all(pagination_parameters)
  end
  helper_method :collection
end
