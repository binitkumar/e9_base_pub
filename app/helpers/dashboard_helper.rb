module DashboardHelper
  def print_friendly_page_link
    text = e9_t(:print_friendly_page_link_text)

    link_to(text, "#print", {
      :id    => :print_friendly_page_link,
      :alt   => text,
      :title => text,
      :rel   => "print",
      :class => "icon-print"
    })
  end
  
  def delete_element_link(element)
    text = e9_t(:dashboard_delete_element_link, :element => element.class.model_name.human)
    path_args = [element]
    path_args.unshift(:admin) unless Topic === element
    link_to(e9_t(:delete_link), polymorphic_path(path_args), {
      :method => :delete,
      :alt => text,
      :title => text,
      :id => 'delete-element-link',
      :confirm => e9_t(:confirmation_question),
      :class => "icon-delete"
    })
  end

  def edit_element_link(element)
    text = e9_t(:dashboard_edit_element_link, :element => element.class.model_name.human)
    path_args = [element]
    path_args.unshift(:admin) unless Topic === element
    link_to(e9_t(:edit_link), edit_polymorphic_path(path_args), {
      :alt => text,
      :title => text,
      :id => 'edit-element-link',
      :class => "icon-edit"
    })
  end

  def hide_legend?(opts = {})
    false_value?(opts[:legend])
  end
end
