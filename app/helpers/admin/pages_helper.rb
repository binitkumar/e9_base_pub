module Admin::PagesHelper
  def change_page_layout_link(page)
    link_to_popup e9_t(:change_layout_link), polymorphic_path([:layouts_admin, page])
  end
end
