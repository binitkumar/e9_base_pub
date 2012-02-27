require 'spec_helper'

describe FavoritablesObserver do
  before do 
    @observer = FavoritablesObserver.instance
    @non_favoriter = Factory(:user, :auto_favorite => false)
    @favoriter     = Factory(:user, :auto_favorite => true)
  end

  context "favoritable is a user_page:" do
    before { @favoritable = Factory(:user_page) }
    context "publish_content" do
      before { @observer.publish_content(@favoritable) }
      it { Favorite.count.should == 1 }
      it { @favoriter.favorites.map(&:favoritable).should == [@favoritable] }
      it { @non_favoriter.favorites.should be_empty }
    end
  end

  context "favoritable is a topic:" do
    before { @favoritable = Factory(:topic) }
    context "publish_content" do
      before { @observer.publish_content(@favoritable) }
      it { Favorite.count.should == 1 }
      it { @favoriter.favorites.map(&:favoritable).should == [@favoritable] }
      it { @non_favoriter.favorites.should be_empty }
    end
  end
end
