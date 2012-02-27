module Admin::SnippetsHelper
  def revert_snippet_link(snippet)
    link_to e9_t(:revert_link), revert_admin_snippet_path(snippet), :remote => true, :method => :put, :confirm => e9_t(:confirmation_question)
  end
end
