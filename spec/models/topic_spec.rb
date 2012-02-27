require 'spec_helper'

describe Topic do
  before { @topic = Factory.create(:topic) }
  it { @topic.should be_valid }

  it "should generate a permalink like id-title" do
    @topic = Factory(:topic, :title => "slug-safe-title")
    @topic.permalink.should == "#{@topic.id}-#{@topic.title}"
  end

  context "with no forum" do
    before { @topic.forum_id = nil }
    it { @topic.save; @topic.errors[:forum_id].should_not be_empty }
  end
  context "with comments" do
    before do
      5.times { @topic.comments << Factory.build(:comment) }
      @topic.reload
    end
    it { @topic.comments.length.should == 6 }
    it { @topic.replies.length.should == 6 }
    it { @topic.comments_count.should == 6 }
    it { @topic.replies_count.should == 6 }
  end
end
