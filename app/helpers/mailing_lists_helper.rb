module MailingListsHelper
  def default_mailing_list
    @_default_mailing_list ||= MailingList.default
  end

  def user_form_checked_box?(user, mailing_list)
    if user
      user.new_record? && mailing_list.system? or user.mailing_lists.include?(mailing_list)
    else
      mailing_list.system?
    end
  end

  def mailing_lists_for_user(user)
    lists = MailingList.order("newsletter DESC, description ASC").for_roles(user.roles)
    lists = lists.newsletters if user.new_record? || user.elevating?
    lists = lists.all

    if ml = MailingList.newsletter
      lists.unshift( lists.slice!( lists.index(ml) ) )
    end

    lists
  end
end
