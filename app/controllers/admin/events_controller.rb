class Admin::EventsController < Admin::PagesController
  include E9::Controllers::View

  carrierwave_column_methods :thumb, :context => :admin
  add_resource_breadcrumbs

  has_scope :with_registration_count, :only => :index, :type => :boolean, :default => true

  has_scope :future, :only => :index, :default => '1' do |controller, scope, value|
    scope.future(E9.true_value?(value))
  end

  protected

    def default_ordered_dir
      'ASC'
    end

    def default_ordered_on
      'event_time'
    end

    ##
    # E9::Controllers::View
    #
    def params_for_build
      params[resource_instance_name] ||= {}
      params[resource_instance_name][:user_id] ||= current_user.id
      params[resource_instance_name]
    end

end
