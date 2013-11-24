require 'spec_helper'

describe Connection do
  before { @connection = Connection.new }
  it "should have my username" do 
    @connection.username.should == 'oblakeerickson'
  end

  it "should have a rate limit" do 
    @connection.rate_limit.should be_kind_of(Integer)
  end

end