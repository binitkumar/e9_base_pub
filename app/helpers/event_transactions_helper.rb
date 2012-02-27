module EventTransactionsHelper
  def cc_date_select_options
    {
      :use_month_numbers => true,
      :start_year        => Time.now.year, 
      :end_year          => Time.now.year + 15,
      :discard_day       => true
    }
  end

  def render_event_registration_success(resource, parent)
    if template = parent.event_registration_message
      liquid_env.merge!({
        'event'        => parent,
        'transaction'  => resource
      })

      k(template)
    end
  end
end
