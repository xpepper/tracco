class TrackingFactory
  DURATION_REGEXP = '(\d+\.?\d*[phdg])'

  def self.build_from(tracking_notification)
    case tracking_notification.data['text']
    when /\[#{DURATION_REGEXP}\]/
      tracking_class = EstimateTracking
    when /\+#{DURATION_REGEXP}/
      tracking_class = EffortTracking
    when /DONE/
      tracking_class = CardDoneTracking
    else
      tracking_class = InvalidTracking
    end

    tracking_class.new(tracking_notification)
  end

end
