class SalesEmail < Email

  def prepare_locals(user_locals = {})
    this_locals.stringify_keys.merge(super(user_locals))
  end

  def allowed_keys
    this_locals.merge(super).keys.sort
  end

  private

  def this_locals
    {
      'sales_contact_email'         => 'sales@contact.com',
      'sales_contact_first_name'    => 'Sales',
      'sales_contact_last_name'     => 'Contact',
      'sales_contact_project_notes' => 'Project Notes: 1, 2, 3',
      'view_sales_lead_URL'         => 'view.sales_lead.com'
    }
  end
end
