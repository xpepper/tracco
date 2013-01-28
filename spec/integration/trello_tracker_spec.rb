require 'spec_helper'
require 'ostruct'

describe TrelloTracker do

  before(:each) do
    @original_error_level = Trello.logger.level
  end

  after(:each) do
    Trello.logger.level = @original_error_level
  end

  let(:config) {
    # auth params for trackinguser_for_test/testinguser!
    OpenStruct.new(tracker_username:  "trackinguser_for_test",
                   developer_key:     "ef7c400e711057d7ba5e00be20139a33",
                   access_token:      "9047d8fdbfdc960d41910673e300516cc8630dd4967e9b418fc27e410516362e")
  }

  it "tracks an estimate", :needs_valid_configuration => true do
    with_trackinguser(config.tracker_username) do
      tracker = TrelloTracker.new("developer_public_key" => config.developer_key, "access_token_key" => config.access_token)
      tracker.track(DateTime.parse("2013-01-28"))

      tracked_card = TrackedCard.first
      tracked_card.estimates.should have(1).estimate
      tracked_card.estimates.first.amount.should == 4
    end
  end

  private

  def with_trackinguser(tracking_user, &block)
    original_tracker = ENV["tracker_username"]
    begin
      ENV["tracker_username"] = tracking_user
      block.call unless block.nil?
    ensure
      ENV["tracker_username"] = original_tracker
    end
  end
end
