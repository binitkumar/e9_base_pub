require 'spec_helper'

describe Faq do
  before { @faq = Factory(:faq) }
  it { @faq.should be_valid }

  describe "having questions" do
    before do
      2.times { Factory(:question, :faq => @faq) }
      @faq.reload
    end

    context "should not be destroyable" do
      before do
        begin
          @faq.destroy
        rescue => @error
        end
      end
      it { @error.should be_an_instance_of(ActiveRecord::DeleteRestrictionError) }
      it { lambda{ Faq.find(@faq.id) }.should_not raise_error }
    end

  end
end
