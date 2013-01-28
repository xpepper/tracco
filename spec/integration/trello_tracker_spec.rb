require 'spec_helper'

describe TrelloTracker do

  before(:each) do
    @original_error_level = Trello.logger.level
  end

  after(:each) do
    Trello.logger.level = @original_error_level
  end

  it "tracks an estimate", :needs_valid_configuration => true do
    # auth params for trackinguser_for_test/testinguser!
    trackinguser_auth_params = { "developer_public_key" => "ef7c400e711057d7ba5e00be20139a33",
                                 "developer_secret"     => "12fe25d85fe1a09fdd30eb57178ff9f07f8dda147d2881e76a0db9eeffc8dfd3",
                                 "access_token_key"     => "9047d8fdbfdc960d41910673e300516cc8630dd4967e9b418fc27e410516362e" }

    with_trackinguser("trackinguser_for_test") do
      tracker = TrelloTracker.new(trackinguser_auth_params)
      tracker.track

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
