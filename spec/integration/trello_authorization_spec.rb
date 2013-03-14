require 'spec_helper'
require 'trello'

describe "Trello Authorization" do
  include Tracco::TrelloAuthorize

  let(:config) {
    # auth params for trackinguser_for_test/testinguser!
    trello_testing_board_auth_params
  }

  it "authorizes connection to Trello", :needs_valid_configuration => true do
    authorize_on_trello(developer_public_key: config.dev_key, access_token_key: config.token)

    Trello::Member.find("me").username.should == "trackinguser_for_test"
  end
end
