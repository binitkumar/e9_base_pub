module E9::DestroyRestricted
  module Controller
    extend ActiveSupport::Concern

    def destroy_resource(object)
      begin
        object.destroy
      rescue Authorization::NotAuthorized => e
        object.errors.add(:base, :insufficient_permission)
      rescue ActiveRecord::DeleteRestrictionError => e
        reflection = /Cannot delete record because of dependent (.*)$/.match(e.message)[1]

        # This is to solve a bug with corrupted counter_cache_columns keeping the record
        # from being deleted.
        if !object.send(reflection).loaded?
          object.send(reflection).reload
          retry
        else
          object.errors.add(reflection.underscore.downcase.to_sym, :delete_restricted)
        end
      ensure
        if object.errors.any?
          flash[:alert] = object.errors.first.last
        end
      end
    end

    protected :destroy_resource
  end

  module Model
    extend ActiveSupport::Concern

    # TODO :admin context should not be specified in destroy_restricted model
    #
    #      having to specify the context here isn't right.  Need a way to
    #      specify this at the controller level while still permitting the action,
    #      which is the whole point of this module.  The controller should
    #      be able to handle NotAuthorized errors in the same way as DeleteRestriction
    #
    included do
      before_destroy do |object|
        Authorization::Engine.instance.permit!([:destroy, :delete], :object => object, :context => :admin)
      end
    end
  end
end
