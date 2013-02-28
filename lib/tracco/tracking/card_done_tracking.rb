module Tracco
  module Tracking
    class CardDoneTracking
      include Base

      def add_to(card)
        card.done = true
      end

    end
  end

end
