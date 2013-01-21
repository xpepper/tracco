class TrackingFactory
  DURATION_REGEXP = '(\d+\.?\d*[phdg])'

  def self.build_from(tracking_notification)
    case tracking_notification.data['text']
    when /\[#{DURATION_REGEXP}\]/
      EstimateTracking.new(tracking_notification)
    when /\+#{DURATION_REGEXP}/
      EffortTracking.new(tracking_notification)
    when /DONE/
      CardDoneTracking.new(tracking_notification)
    else
      Trello.logger.warn "Ignoring tracking notification: #{tracking_notification}"
    end
  end

end
