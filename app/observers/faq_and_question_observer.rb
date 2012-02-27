class FaqAndQuestionObserver < ActiveRecord::Observer
  observe :faq, :question

  def after_save(record)
    Page.find_by_identifier(Page::Identifiers::FAQ).try(:update_attribute, :updated_at, DateTime.now)
  end
end
