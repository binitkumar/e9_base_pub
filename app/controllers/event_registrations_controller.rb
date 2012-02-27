class EventRegistrationsController < InheritedResources::Base
  belongs_to :event, :finder => :find_by_permalink!
  actions :new

  respond_to :json
  respond_to :html, :except => :new

  def new
    new! do
      unless guests_under_limit?
        head 409 and return false
      end
    end
  end

  protected

    def guests_under_limit?
      params[:guests].to_i < parent.event_max_guests
    end

    def build_resource
      get_resource_ivar || begin
        @transaction = parent.event_transactions.build
        @transaction.event_registrations.build(:event => parent)
      end
    end

end
