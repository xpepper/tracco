class TrelloTracker
  include TrelloAuthorize
  include Trello

  trap("SIGINT") { exit! }

  def initialize(custom_config_params = {})
    authorize_on_trello(custom_config_params)
    tracker_username(custom_config_params[:tracker_username])
  end

  def track(starting_date=Date.today)
    tracking_notifications = tracker.tracking_notifications_since(starting_date)

    oldest, latest = boundary_dates_in(tracking_notifications)
    Trello.logger.info "Processing #{tracking_notifications.size} tracking events (from #{oldest} to #{latest}) starting from #{starting_date}..."

    tracking_notifications.each do |tracking_notification|
      tracking = Tracking::Factory.build_from(tracking_notification)
      begin
        tracked_card = TrackedCard.update_or_create_with(tracking_notification.card)
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

  def boundary_dates_in(tracking_notifications)
    dates = tracking_notifications.map { |each_tracking_notification| Chronic.parse(each_tracking_notification.date) }
    [dates.min, dates.max]
  end

end
