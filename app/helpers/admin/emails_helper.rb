module Admin::EmailsHelper
  def mailing_list_select_options
    lists = MailingList.newsletters.order("name ASC")

    if ml = MailingList.newsletter
      lists.unshift( lists.slice!( lists.index(ml) ) )
    end

    lists.map {|m| [m.name, m.id] }
  end

  def send_test_email_link(email, opts = {})
    opts[:method] = :put
    opts[:remote] = true
    link_to e9_t(:send_test_email_link), polymorphic_path([:send_email_admin, email], :test => true), opts
  end

  def send_email_to_list_link(email, opts = {})
    opts[:confirm] = e9_t(:confirmation_question)
    opts[:method]  = :put
    opts[:remote]  = :true
    link_to e9_t(:send_email_link), polymorphic_path([:send_email_admin, email]), opts
  end

  def copy_email_link(email, opts = {})
    link_to_new_resource t(:copy), email, :copy_id => email.id
  end

  def email_active_select
    @_email_active_select_options ||= [
      [Email.human_attribute_name('active'),     nil],
      [Email.human_attribute_name('inactive'),  true]
    ]

    select_tag :inactive, options_for_select(@_email_active_select_options, params[:inactive])
  end
end
