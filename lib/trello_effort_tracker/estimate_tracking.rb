class EstimateTracking
  include Tracking

  def estimate
    estimate = convert_to_hours(raw_estimate)
    Estimate.new(amount: estimate, date: date, tracking_notification_id: @tracking_notification.id)
  end
  
  def add_to(card)
    card.estimates << estimate if card.estimates.none? {|e| e.tracking_notification_id == self.estimate.tracking_notification_id}
  end
  
end
