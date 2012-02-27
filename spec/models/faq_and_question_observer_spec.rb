require 'spec_helper'

describe FaqAndQuestionObserver do
  before do 
    @observer  = FaqAndQuestionObserver.instance
    @faqs_page = Factory(:page, :identifier => Page::Identifiers::FAQ, :updated_at => DateTime.now - 1.day)
  end

  describe "after_save" do
    it "should touch the faqs page after saving a question" do
      @faqs_page.reload.updated_at.day.should_not == DateTime.now.day
      @observer.after_save(Factory(:question))
      @faqs_page.reload.updated_at.day.should == DateTime.now.day
    end
    it "should touch the faqs page after saving a faq" do
      @faqs_page.reload.updated_at.day.should_not == DateTime.now.day
      @observer.after_save(Factory(:faq))
      @faqs_page.reload.updated_at.day.should == DateTime.now.day
    end
  end
end
