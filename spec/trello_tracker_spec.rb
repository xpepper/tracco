require 'spec_helper'

describe TrelloTracker do

  before(:each) do
    @original = ENV["tracker_username"]
    ENV["tracker_username"] = "my_tracker"
  end
  
  after(:each) do
    ENV["tracker_username"] = @original
  end
  
  it "force the trello tracker username in the constructor" do    
    tracker = TrelloTracker.new(tracker_username: "any_other_tracker")

    tracker.tracker_username.should == "any_other_tracker"
  end

  it "takes the tracker username from the ENV var tracker_username" do
    tracker = TrelloTracker.new

    tracker.tracker_username.should == "my_tracker"
  end

end
