class TrelloTracker
  include TrelloAuthorize
  include Trello

  trap("SIGINT") { exit! }

  def initialize(custom_config_params = {})
    authorize_on_trello(custom_config_params)
    tracker_username(custom_config_params[:tracker_username])
  end

  def track(starting_date=Date.today)
    tracking_events = tracker.tracking_events_since(starting_date)

    oldest, latest = boundary_dates_in(tracking_events)
    Trello.logger.info "Processing #{tracking_events.size} tracking events (from #{oldest} to #{latest}) starting from #{starting_date}..."

    tracking_events.each do |tracking_event|
      tracking = Tracking::Factory.build_from(tracking_event)
      begin
        tracked_card = TrackedCard.update_or_create_with(tracking_event.card)
        tracked_card.add!(tracking)
        Trello.logger.info tracking

      rescue StandardError => e
        Trello.logger.warn "skipping tracking: #{e.message}".color(:magenta)
        Trello.logger.debug "#{e.backtrace}"
      end
    end
    Trello.logger.info "Done tracking cards!".color(:green)
  end

  private

  def tracker
    @tracker ||= Member.find(tracker_username)
  end

  def boundary_dates_in(tracking_events)
    dates = tracking_events.map { |each_tracking_event| Chronic.parse(each_tracking_event.date) }
    [dates.min, dates.max]
  end

end
