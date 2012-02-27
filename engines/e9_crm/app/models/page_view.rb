# A visit to the site
# 
# Page views belong to a tracking cookie, from which it derives its
# campaign code, and whether or not it is a "new visit" for the given
# campaign code.
#
# === Also stored from the request:
#
# [request_path] The full request path
# [user_agent]   The request user agent
# [referer]      The request referer if it exists
# [remote_ip]    The originating ip address of the request
# [session]      The session id of the request
#
class PageView < ActiveRecord::Base
  belongs_to :tracking_cookie

  belongs_to :campaign, :inverse_of => :page_views
  has_one :user, :through => :tracking_cookie

  scope :by_users, lambda {|*users| 
    joins(:tracking_cookie) & TrackingCookie.for_users(users)
  }

  scope :new_visits,    lambda {|v=true| where(:new_visit => v) }
  scope :repeat_visits, lambda { new_visits(false) }

  delegate :name, :code, :to => :campaign, :prefix => true, :allow_nil => true
  delegate :contact, :to => :user, :allow_nil => true

  def self.visits_by_contact
    sel_sql = <<-SQL.gsub(/\s+/, ' ')
      page_views.*,
      IF(contacts.id,CONCAT_WS(' ', contacts.first_name, contacts.last_name),'(Unknown)') contact_name,
      contacts.id as contact_id,
      count(distinct(if(page_views.new_visit=1,IFNULL(page_views.session,1),null))) as new_visits,
      count(distinct(if(page_views.new_visit=1,null,IFNULL(page_views.session,1)))) as repeat_visits
    SQL

    join_sql = <<-SQL.gsub(/\s+/, ' ')
      LEFT OUTER JOIN tracking_cookies
        ON tracking_cookies.id = page_views.tracking_cookie_id
      LEFT OUTER JOIN users
        ON users.id = tracking_cookies.user_id
      LEFT OUTER JOIN contacts
        ON contacts.id = users.contact_id
    SQL
      
    select(sel_sql).joins(join_sql).group('contact_id')
  end
end
