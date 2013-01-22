module Tracking
  class EstimateTracking
    include Base

    #TODO: rename to 'amount' ?
    #TODO: avoid recomputing estimate every time using a lazy instance variable
    def estimate
      estimate = convert_to_hours(raw_estimate)
      Estimate.new(amount: estimate, date: date, tracking_notification_id: tracking_notification.id)
    end

    def add_to(card)
      card.estimates << estimate unless card.contains_estimate?(estimate)
    end

    private

    def raw_estimate
      extract_match_from_raw_tracking(/\[#{DURATION_REGEXP}\]/)
    end

  end
end
