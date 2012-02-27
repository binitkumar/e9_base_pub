module Admin::ShareSitesHelper
  def share_site_row_class(share_site)
    if @active.nil?
      @active, @to_activate = 0, enabled_count()
    end

    if @active < @to_activate && share_site.enabled?
      @active += 1
      'active'
    else
      'inactive'
    end
  end
end
