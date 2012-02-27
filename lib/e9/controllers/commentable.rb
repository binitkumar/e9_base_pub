module E9::Controllers
  module Commentable
    extend ActiveSupport::Concern

    included do
      prepend_before_filter :check_honeypot, :only => [:create, :update]
      before_filter :build_initial_comment,  :only => :show
    end

    def build_initial_comment
      @comment ||= current_user.comments.build(:commentable => resource) if current_user
    end

    ##
    # bounce bots happily
    #
    def check_honeypot
      unless params[resource_instance_name] && params[resource_instance_name].delete(:email).blank?
        flash[:notice] = I18n.t(:notice, :scope => :"flash.actions.create", :resource_name => resource_instance_name)
        respond_with(build_resource) do |format|
          format.js { head :ok }
          format.html { redirect_to(collection_path) }
        end
      end
    end

    protected :build_initial_comment, :check_honeypot
  end
end
