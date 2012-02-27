module EventRegistrationsHelper
  def event_registration_template(transaction)
    buffer = ''.html_safe

    lookup_context.update_details(:formats => [Mime::HTML.to_sym]) do
      fields_for(transaction) do |f|
        f.fields_for(:event_registrations, :child_index => params[:child_index] || 10000) do |ff|
          buffer.concat record_attribute_template(:event_registration, ff)
        end
      end
    end

    buffer
  end
end
