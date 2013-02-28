require 'spec_helper'

module Tracco
  module Tracking
    describe CardDoneTracking do

      describe "#add_to" do
        it "marks the card as done" do
          card = TrackedCard.new

          done_tracking = Tracking::Factory.build_from(notification_with_message("DONE"))
          done_tracking.add_to(card)

          card.done?.should be_true
        end
      end

    end
  end
end
