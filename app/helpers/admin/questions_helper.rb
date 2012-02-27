module Admin::QuestionsHelper

  #
  # accepts option 'force_id', a sloppy quick-fix to the fact that the question in-form select needs faq_id
  # and the dropdown in questions#index uses to_param to build the url
  #
  def faq_select_array(opts = {})
    @faq_select_array ||= Faq.for_roleable(current_user).order("title ASC").map {|f| [f.title, opts[:force_id] ? f.id : f.to_param] }
  end

  # used in questions#index
  #
  def faq_category_select(faq)
    select_tag 'faq_id', options_for_select(faq_select_array, faq.to_param)
  end
end
