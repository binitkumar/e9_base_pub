require 'spec_helper'

describe UserObserver do
  before do
    @observer = UserObserver.instance
    @user = Factory(:user)
  end

  context "before_save" do
    context "auto favoriting" do
      before do
        @not_favoritables = 2.times.map { Factory(:system_page) }
        @favoritables     = 2.times.map { Factory(:user_page) }
        @favoritables    += 2.times.map { Factory(:topic) }

        @user.favorites.create(:favoritable => @favoritables.first)
      end
      context "when changing to true" do
        before { @user.update_attribute(:auto_favorite, false); @user.auto_favorite = true }
        it "should reset and assign all favoritable records to user" do
          @observer.before_save(@user)
          @user.favorites.map(&:favoritable).should =~ @favoritables
        end
      end
      context "when changing to false" do
        before { @user.update_attribute(:auto_favorite, true); @user.auto_favorite = false }
        it "should not affect user's favorites" do
          @observer.before_save(@user)
          @user.favorites.length.should == 1
        end
      end
      context "when unchanged" do
        before { @user.update_attribute(:auto_favorite, true); @user.auto_favorite = true }
        it "should not affect user's favorites" do
          @observer.before_save(@user)
          @user.favorites.length.should == 1
        end
      end
    end
  end

  context "after_create" do
    before do
      @comment_updates_list = MailingList.create!(:identifier => MailingList::Identifiers::COMMENT_UPDATES, :name => "Comments and Topics Notification", :description => 'Email me when people comment on topics & pages that I saved or where I commented', :system => true, :newsletter => false)
    end
    context "mailing lists" do
      it "should auto subscribe to comment_updates" do
        @observer.after_create(@user)
        @user.mailing_lists.should include(@comment_updates_list)
      end
    end
    context "auto favoriting" do
      before do
        @not_favoritables = 2.times.map { Factory(:system_page) }
        @favoritables     = 2.times.map { Factory(:user_page) }
        @favoritables    += 2.times.map { Factory(:topic) }
      end
      it "should do nothing if auto_favorite is not true" do
        @user = Factory(:user, :auto_favorite => false)
        @observer.after_create(@user)
        @user.favorites.should be_empty
      end
      it "should assign all favorites if auto_favorite is true" do
        @user = Factory(:user, :auto_favorite => true)
        @observer.after_create(@user)
        @user.favorites.map(&:favoritable).should =~ @favoritables
      end
    end
  end
end
