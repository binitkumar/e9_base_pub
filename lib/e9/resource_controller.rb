module E9::ResourceController
  extend ActiveSupport::Concern

  included do
    inherit_resources
    filter_access_to :edit, :update, :attribute_check => true, :load_method => :resource, :context => :admin
    include E9::DestroyRestricted::Controller
  end
end
