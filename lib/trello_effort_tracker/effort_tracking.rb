class EffortTracking
  include Tracking

  def effort
    effort_amount = convert_to_hours(raw_effort)
    if effort_amount
      total_effort = effort_amount * effort_members.size
      Effort.new(amount: total_effort, date: date, members: effort_members, tracking_notification_id: @tracking_notification.id)
    end
  end

  def add_to(card)  
    card.efforts << effort if card.efforts.none? {|e| e.tracking_notification_id == self.effort.tracking_notification_id}
  end

end
