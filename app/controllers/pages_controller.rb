class PagesController < ApplicationController
  include PublicFacingController
  inherit_resources
  defaults :instance_name => :current_page
  actions :show

  filter_access_to :show, :attribute_check => true, :load_method => :find_current_page, :context => :pages

  add_dynamic_breadcrumbs

  respond_to :html

  protected

    def resource
      @current_page ||= begin
        current_page = if @path.blank?
          LinkableSystemPage.home_page
        else 
          ContentView.
              pages.
              includes(:author, :comments => [:flag, :author]).
              find_by_permalink!(@path)
        end

        current_page.increment_hits! if current_page.kind_of?(Hittable)
        current_page
      end
    end
    alias :find_current_page :resource

end
