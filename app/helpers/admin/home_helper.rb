module Admin::HomeHelper
  def flagged_comments_notification
    ''.html_safe.tap do |html|
      if (count = Flag.comment_count).zero?
        html << e9_t(:flagged_comments_empty)
      else
        html << e9_t(:flagged_comments_message, :count => count).html_safe
        html << ' '
        html << link_to(e9_t(:flagged_comments_link), flagged_admin_comments_path)
      end
    end
  end

  def new_leads_notification(day_range = 7)
    count = Deal.leads.from_time(Date.today - day_range.days).count

    ''.html_safe.tap do |html|
      if count.zero?
        html << e9_t(:new_leads_empty)
      else
        html << e9_t(:new_leads_message, :count => count, :days => day_range).html_safe
        html << ' '
        html << link_to(e9_t(:new_leads_link), leads_path)
      end
    end
  end
end
