require 'spec_helper'

describe Connection do
  before { @connection = Connection.new }
  it "should have my username" do
    @connection.username.should == 'oblakeerickson'
  end

  it "should have a rate limit" do
    @connection.rate_limit.should be_kind_of(Integer)
  end

  it "should be a list of users" do
    @connection.user_list(0).should be_kind_of Array
  end

  it "should return last user id" do
    list = @connection.user_list(0)
    @connection.last_user(list).should be_kind_of(Integer)
  end

end