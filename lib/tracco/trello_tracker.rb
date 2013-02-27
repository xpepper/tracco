class TrelloTracker
  include TrelloAuthorize
  include Trello

  trap("SIGINT") { exit! }

  def initialize(custom_config_params = {})
    authorize_on_trello(custom_config_params)
    tracker_username(custom_config_params[:tracker_username])
  end

  def track(starting_date=Date.today)
    notifications = tracker.notifications_since(starting_date)

    oldest, latest = boundary_dates_in(notifications)
    Trello.logger.info "Processing #{notifications.size} tracking events (from #{oldest} to #{latest}) starting from #{starting_date}..."

    notifications.each do |notification|
      tracking = Tracking::Factory.build_from(notification)
      begin
        tracked_card = TrackedCard.update_or_create_with(notification.card)
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

  def boundary_dates_in(notifications)
    dates = notifications.map { |each_notification| Chronic.parse(each_notification.date) }
    [dates.min, dates.max]
  end

end
