require 'spec_helper'

describe Comment do
  before { @comment = Factory.build(:comment) }

  it { @comment.should be_valid }

  describe "body" do
    it "should be HTML sanitized before save" do
      @comment.body = "<p><b>Body</b> without <a href=\"asdf\">HTML</a></p>"
      @comment.save
      @comment.body.should == "Body without HTML"
    end
  end

  it "should touch its parent" do
    @past_updated_at = DateTime.now - 1.week
    @comment.commentable = @topic = Factory(:topic, :updated_at => @past_updated_at)

    proc { @comment.save }.should change(@topic, :updated_at).
      from(@past_updated_at).
      to(@comment.updated_at)
  end

  it "should increment its parent's comments_count" do
    @topic = Factory(:topic)

    proc { @topic.comments.create(Factory.attributes_for(:comment)); @topic.reload }.
      should change(@topic, :comments_count).by(1)
  end


end
