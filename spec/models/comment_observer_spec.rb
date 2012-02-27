require 'spec_helper'

describe CommentObserver do
  context "after_create" do
    before do 
      SystemEmail.stub!(:comment_update).and_return(@mock_email = MockEmail.new)

      @observer = CommentObserver.instance
      @users = 3.times.map { Factory(:user) }
      @topic = Factory(:topic, :author => @users[0])
    end

    context "given users who elect to receive comment updates" do
      it "should mail to the commenters (who did not make the comment)" do
        Factory(:comment, :commentable => @topic, :author => @users[0])
        Factory(:comment, :commentable => @topic, :author => @users[1])
        @comment = Factory(:comment, :commentable => @topic.reload, :author => @users[1])

        @observer.after_create(@comment)
        @mock_email.recipients.should == [@users[0]]
      end

      it "should mail to the favoriters (who did not make the comment)" do
        Factory(:favorite, :favoritable => @topic, :user => @users[0])
        Factory(:favorite, :favoritable => @topic, :user => @users[1])
        @comment = Factory(:comment, :commentable => @topic.reload, :author => @users[1])

        @observer.after_create(@comment)
        @mock_email.recipients.should == [@users[0]]
      end
    end
  end
end
