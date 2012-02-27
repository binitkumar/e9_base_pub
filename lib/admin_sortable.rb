module AdminSortable
  module Controller
    extend ActiveSupport::Concern

    def update_order(options = {}, &block)
      if params[:ids].is_a?(Array)
        pos = 0
        params[:ids].each {|id| pos += 1; _do_position_update(id, :position => pos) }
        flash[:notice] = I18n.t(:notice, :scope => :"flash.actions.update_order")
      else
        flash[:alert]  = I18n.t(:alert,  :scope => :"flash.actions.update_order")
      end
      
      block ||= proc do |format|
                  format.js { head :ok }
                end

      respond_with(collection, &block)
    end

    alias :update_order! :update_order

    def _do_position_update(id, hash_with_position)
      resource_class.update(id, hash_with_position)
    end

    private :_do_position_update
  end
end
