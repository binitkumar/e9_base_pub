module FriendEmailsHelper
  def friend_email_link(linkable)
    link_title = e9_t(:link_title, :scope => :friend_emails)

    link_to_popup(link_title, new_friend_email_path(:link_id => linkable.link.id), {
      :id    => :friend_email_link,
      :alt   => link_title,
      :title => link_title,
      :class => "icon-friend-email"
    })
  end
end
