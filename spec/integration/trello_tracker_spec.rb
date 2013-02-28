require 'spec_helper'
require 'ostruct'

module Tracco
  describe TrelloTracker do
    # This integration test works on a real Trello board created just for this purpose
    # (see https://trello.com/board/testingboard/50ff225c7162123e3600074f)
    # The board has some cards in todo, one card in progress and one done

    TODO_CARD_ID         =  "51062b71df2bfec47b0039fb"
    IN_PROGRESS_CARD_ID  =  "51062b99d81a343121004046"
    DONE_CARD_ID         =  "51062b936d2deed22100157e"
    ANOTHER_DONE_CARD_ID =  "510c46d7c7bc9ac6020007ab"

    let(:config) {
      # auth params for trackinguser_for_test/testinguser!
      OpenStruct.new(tracker:  "trackinguser_for_test",
                     dev_key:  "ef7c400e711057d7ba5e00be20139a33",
                     token:    "9047d8fdbfdc960d41910673e300516cc8630dd4967e9b418fc27e410516362e")
    }

    it "tracks some estimates and efforts", :needs_valid_configuration => true do
      without_logging do
        tracker = TrelloTracker.new(tracker_username: config.tracker, developer_public_key: config.dev_key, access_token_key: config.token)
        tracker.track(DateTime.parse("2013-01-28"))
      end

      # a card to do
      todo_card = TrackedCard.find_by_trello_id(TODO_CARD_ID)

      todo_card.estimates.should have(1).estimate
      todo_card.estimates.first.amount.should == 4
      todo_card.should_not be_done

      # a card in progress
      in_progress_card = TrackedCard.find_by_trello_id(IN_PROGRESS_CARD_ID)

      in_progress_card.estimates.should have(1).estimate
      in_progress_card.estimates.should have(1).effort
      in_progress_card.estimates.first.amount.should == 5
      in_progress_card.efforts.first.amount.should == 1
      in_progress_card.should_not be_done

      # a done card
      done_card = TrackedCard.find_by_trello_id(DONE_CARD_ID)
      done_card.total_effort.should == 2
      done_card.should be_done

      # another done card (this time for the DONE column)
      another_done_card = TrackedCard.find_by_trello_id(ANOTHER_DONE_CARD_ID)
      another_done_card.should be_done
    end


    private

    def without_logging(&block)
      original_error_level = Trello.logger.level

      begin
        Trello.logger.level = Logger::WARN
        block.call unless block.nil?
      ensure
        Trello.logger.level = original_error_level
      end
    end
  end
end
