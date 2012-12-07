class TrelloTracker
  include TrelloAuthorize
  include Trello

  trap("SIGINT") { exit! }

  def initialize(custom_auth_params = {})
    authorize_on_trello(custom_auth_params)
  end

  def track(from_date=Date.today)
    notifications = tracker.notifications_from(from_date)

    oldest, latest = boundary_dates_in(notifications)
    Trello.logger.info "Processing #{notifications.size} tracking notifications (from #{oldest} to #{latest}) starting from #{from_date}..."

    notifications.each do |notification|
      tracking = Tracking.new(notification)
      begin
        existing_card = TrackedCard.with_trello_id(tracking.card.trello_id)
        Trello.logger.debug "Tracked card found: #{existing_card.name} with trello_id: #{existing_card.id}" if existing_card

        card = existing_card || tracking.card
        card.add(tracking)
        card.save

        Trello.logger.info tracking

      rescue StandardError => e
        Trello.logger.error "skipping tracking: #{e.message}".color(:magenta)
        Trello.logger.error "#{e.backtrace}"
      end
    end
    Trello.logger.info "Done tracking cards!".color(:green)
    print_all_cards
  end

  def tracker
    @tracker ||= Member.find(tracker_username)
  end

  private

  def boundary_dates_in(notifications)
    dates = notifications.map { |each_notification| Chronic.parse(each_notification.date) }
    [dates.min, dates.max]
  end

  def print_all_cards
    TrackedCard.all.each { |tracked_card| Trello.logger.info(tracked_card.to_s.color(:yellow)) }
  end

end
