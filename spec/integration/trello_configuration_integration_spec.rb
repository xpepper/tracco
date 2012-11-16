require 'spec_helper'
require 'trello'

describe TrelloConfiguration do
  include TrelloConfiguration
  include TrelloAuthorize

  it "load the trello auth params" do
    default_authorization_params["developer_public_key"].should_not be_empty
    default_authorization_params["access_token_key"].should_not be_empty
    default_authorization_params["developer_secret"].should_not be_empty
  end

  it "uses the configured tracker user", :slow => true do
    authorize_on_trello
    
    tracker = Trello::Member.find("me")
    tracker.username.should == tracker_username
  end
end
