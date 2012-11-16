require 'spec_helper'
require 'trello'

describe TrelloAuthorize do
  include TrelloAuthorize
  include TrelloConfiguration

  it "authorizes connection to Trello", :slow => true do
    authorize_on_trello
    
    tracker = Trello::Member.find("me")
    tracker.username.should == tracker_username
  end
end
