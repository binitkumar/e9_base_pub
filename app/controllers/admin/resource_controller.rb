class Admin::ResourceController < AdminController
  inherit_resources

  filter_access_to :update, :edit, :attribute_check => true, :load_method => :filter_target, :context => :admin

  include E9::DestroyRestricted::Controller
  include E9::Roles::Controller

  protected

  def filter_target
    resource
  end
end
