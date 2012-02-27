module E9Crm::PageViewsHelper
  def page_view_campaign_select_options
    @_page_view_campaign_select_options ||= begin
      opts = Campaign.all.map {|campaign| [campaign.name, campaign.id] }
      opts.unshift ['Any', nil]
      options_for_select(opts)
    end
  end

  def page_view_new_visit_select_options
    options_for_select([
      ['Any', nil],
      ['New Visits', true],
      ['Repeat Visits', false]
    ])
  end

  def page_view_date_select_options(options = {})
    @first_view_date ||= begin
      sql = PageView.select('created_at').order('created_at ASC').limit(1).to_sql
      PageView.connection.select_value(sql) || Date.today
    end

    options.merge!({
      :from_date => @first_view_date
    })

    date_select_options(options.merge(:from_date => @first_view_date))
  end
end
