class TasksController < ApplicationController
  before_filter :authenticate_user!
  filter_access_to :all, :context => :admin, :require => :update
  skip_js_skippable_filters

  def deliver_scheduled_email
    Newsletter.deliver_scheduled

    respond_to do |format|
      format.html { redirect_to :root }
    end
  end
end
