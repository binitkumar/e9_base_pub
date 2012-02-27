require 'spec_helper'

describe E9::Roles::Role do
  context "roleable" do
    # should no doubt mock this somehow, but quickly >
    it "should call ensure_default_role on after_initialize callback" do
      Page.new.read_attribute(:role).should_not be_nil
    end
    it "should call ensure_default_role on before_validation callback" do
      @roleable = Page.new
      @roleable.role = nil
      @roleable.read_attribute(:role).should be_nil
      @roleable.valid?
      @roleable.read_attribute(:role).should_not be_nil
    end
  end

  it "guest should not be user_assignable" do
    E9::Roles.user_assignable.should_not be_empty
    E9::Roles.user_assignable.should_not include "guest"
    E9::Roles.user_assignable.sort.should == %w(user employee administrator superuser e9_user).sort
  end

  it "all roles should be content_assignable" do
    E9::Roles.content_assignable.sort.should == E9::Roles.list.sort
    E9::Roles.content_assignable.sort.should == E9::Roles.all.sort
  end

  specify "big fish eat the little ones" do
    E9::Roles.list.map {|l| l.role }.each_cons(2) do |a, b|
      assert b.includes?(a)
    end
  end

  specify "big fish include the little ones" do
    E9::Roles.list.inject([]) do |incs, role_name|
      # each role's includes are itself, and all preceding
      incs << role_name
      role_name.role_included.sort.should == incs.sort
      incs
    end
  end

  specify "NilClass is the bottom role" do
    nil.role == E9::Roles.bottom
  end

  specify "String should name its role" do
    "guest".role.should == E9::Roles::Role.new('guest')
  end

  specify "Symbol should name its role" do 
    :guest.role.should == E9::Roles::Role.new('guest')
  end

end
