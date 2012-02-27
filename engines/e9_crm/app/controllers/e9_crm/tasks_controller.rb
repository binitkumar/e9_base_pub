class E9Crm::TasksController < E9Crm::NotesController
  defaults :resource_class => Task

  filter_access_to :toggle, :require => :create, :context => :admin

  respond_to :json, :only => [:show, :index, :toggle]
  respond_to :html, :except => :toggle

  def toggle
    object = resource
    object.toggle_completed!

    render :json => object
  end
end
