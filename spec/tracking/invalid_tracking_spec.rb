require 'spec_helper'

module Tracco
  module Tracking
    describe InvalidTracking do

      describe "#add_to" do
        it "just logs a warning message and does nothing" do
          Trello.logger.should_receive(:warn).with(/^Ignoring tracking notification:/)

          invalid_tracking = Tracking::Factory.build_from(unrecognized_notification)
          invalid_tracking.add_to(TrackedCard.new)
        end
      end
    end
  end
end
