require 'spec_helper'

describe Question do
  before { @question = Factory(:question); @faq = @question.faq }
  it { @question.should_not be_nil }

  context "parent touching" do
    it "should touch its parent when created with Question.new" do
      @question = Question.new(:faq => @faq, :answer => "asdf", :title => "werwerw")
      proc { @question.save! }.should change(@faq, :updated_at)
    end

    it "should touch its parent when create with parent.questions.build" do
      @question = @faq.questions.build(:faq => @faq, :answer => "asdf", :title => "werwerw")
      proc { @question.save! }.should change(@faq, :updated_at)
    end

    it "should touch its parent on update" do
      proc { @question.update_attribute(:answer, "something") }.should change(@faq, :updated_at)
    end

    it "should touch its parent when changing parents" do
      @question.faq = @faq = Factory(:faq)
      proc { @question.save! }.should change(@faq, :updated_at)
    end

  end
  
  context "changing parents" do
    before do
      @faq_1 = Factory(:faq)
      @question = Factory(:question, :faq => @faq_1)
      2.times { Factory(:question, :faq => @faq_1) }
      @faq_2 = Factory(:faq)
      3.times { Factory(:question, :faq => @faq_2) }

      @question.faq = @faq_2
      @question.save
      @question.reload
    end
    it "should remove itself from the old list" do
      @faq_1.reload
      @faq_1.questions.should_not include(@question)
      @faq_1.questions.order(:position).map(&:position).should == [1,2]
    end
    it "should update move to the end of the new parent's list" do
      @faq_2.reload
      @faq_2.questions.order(:position).map(&:position).should == [1,2,3,4]
      @question.position.should == 4
    end
  end
end
