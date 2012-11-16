require 'spec_helper'
require 'trello'

describe TrelloAuthorize do
  include TrelloAuthorize

  it "authorizes connection to Trello", :slow => true do
    authorize_on_trello
    
    Trello::Member.find("me").should_not be_nil
  end
end
