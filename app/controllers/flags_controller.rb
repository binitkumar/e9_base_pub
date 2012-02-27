class FlagsController < InheritedResources::Base
  belongs_to :page, :comment, :polymorphic => true, :singleton => true
  respond_to :js

  before_filter :prepare_build_params, :only => :create

  protected

  def prepare_build_params
    params[:flag] ||= {}
    params[:flag][:user] = current_user
    params[:flag]
  end
end
