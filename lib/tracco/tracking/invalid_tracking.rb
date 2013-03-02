module Tracco
  module Tracking
    class InvalidTracking
      include Base

      def add_to(card)
        # do nothing
        Trello.logger.warn "Ignoring tracking notification: '#{tracking_message}'"
      end

      def estimate
        nil
      end

      def effort
        nil
      end

    end
  end
end
