class Admin::SocialFeedsController < AdminController
  respond_to :html

  add_resource_breadcrumbs :only => :index
end
