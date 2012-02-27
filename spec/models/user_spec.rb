require 'spec_helper'

describe User do
  before(:each) do
    @user = Factory(:user)
    @user.should be_valid
  end

  it 'should NOT be valid with an invalid email' do
    @user.email = "someinvalidemail"
    @user.should_not be_valid
  end

  it 'should NOT be valid with a duplicate email' do
    Factory.build(:user, :email => @user.email).should_not be_valid
  end

  context 'User.flagged' do
    before do
      @users = 3.times.map { Factory.build(:user) }
      @comments = []
      @comments << Factory(:comment, :author => @users[0])
      @comments << Factory(:comment, :author => @users[0])
      @comments << Factory(:comment, :author => @users[1])
      @comments.each {|c| c.create_flag; c.reload }
    end

    it 'should return each flagged user once' do
      User.flagged.sort_by(&:id).should == [@users[0], @users[1]].sort_by(&:id)
    end
  end

end
