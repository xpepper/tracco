class TrackingFactory

  DURATION_REGEXP = '(\d+\.?\d*[phdg])'

  @match_pairs = {}

  def self.build_from(tracking_notification)
    matching_pair = @match_pairs.find { |regexp, tracking_class| tracking_notification.data['text'] =~ regexp }

    tracking_class = matching_pair ? matching_pair.last : Tracking::InvalidTracking
    tracking_class.new(tracking_notification)
  end

  private

  def self.match(match_pair)
    @match_pairs.merge!(match_pair)
  end

  match /\[#{DURATION_REGEXP}\]/ => Tracking::EstimateTracking
  match /\+#{DURATION_REGEXP}/   => Tracking::EffortTracking
  match /DONE/ => Tracking::CardDoneTracking

end
