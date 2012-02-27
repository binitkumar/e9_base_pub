require 'spec_helper'

describe FavoritesController do
  before do
    @user = Factory(:user)
    5.times { @user.favorites.create(:favoritable => Factory(:user_page)) }
    5.times { @user.favorites.create(:favoritable => Factory(:topic)) }
    request.env['warden'] = mock_warden(@user)
  end
  describe "GET index" do
    before { get :index, :format => :js, :per_page => 100 }
    it { response.should be_success }
    it { assigns(:favorites).length.should == 10 }
    it { assigns(:favorites).each {|fav| fav.should be_an_instance_of(Favorite) } }
  end
  describe "GET pages" do
    before { get :index, :of_type => 'user_page', :format => :js, :per_page => 100}
    it { response.should be_success }
    it { assigns(:favorites).length.should == 5 }
    it { assigns(:favorites).each {|fav| fav.favoritable.should be_an_instance_of(UserPage) } } 
  end
  describe "GET topics" do
    before { get :index, :of_type => 'topic', :format => :js, :per_page => 100}
    it { response.should be_success }
    it { assigns(:favorites).length.should == 5 }
    it { assigns(:favorites).each {|fav| fav.favoritable.should be_an_instance_of(Topic) } } 
  end
  context "paginating" do
    before do
      @pp = 2
    end
    context "GET index" do
      before { get :index, :per_page => @pp, :format => :js }
      it { assigns(:favorites).length.should == @pp }
      it { assigns(:favorites).should =~ @user.favorites.order('created_at DESC').limit(@pp) }
    end
    context "GET pages" do
      before { get :index, :of_type => 'user_page', :per_page => @pp, :format => :js }
      it { assigns(:favorites).length.should == @pp }
      it { assigns(:favorites).should =~ @user.favorites.of_type(:user_page).order('created_at DESC').limit(@pp) }
    end
    context "GET topics" do
      before { get :index, :of_type => 'topic', :per_page => @pp, :format => :js }
      it { assigns(:favorites).length.should == @pp }
      it { assigns(:favorites).should =~ @user.favorites.of_type(:topic).order('created_at DESC').limit(@pp) }
    end
    context "page 2" do
      context "GET index" do
        before { get :index, :offset => @pp, :format => :js, :per_page => @pp }
        it { assigns(:favorites).length.should == @pp }
        it { assigns(:favorites).should =~ @user.favorites.order('created_at DESC').limit(@pp).offset(@pp) }
      end
      context "GET pages" do
        before { get :index, :of_type => 'user_page', :per_page => @pp, :offset => @pp, :format => :js }
        it { assigns(:favorites).length.should == @pp }
        it { assigns(:favorites).should =~ @user.favorites.of_type(:user_page).order('created_at DESC').limit(@pp).offset(@pp) }
      end
      context "GET topics" do
        before { get :index, :of_type => 'topic', :per_page => @pp, :offset => @pp, :format => :js }
        it { assigns(:favorites).length.should == @pp }
        it { assigns(:favorites).should =~ @user.favorites.of_type(:topic).order('created_at DESC').limit(@pp).offset(@pp) }
      end
    end
  end
end
