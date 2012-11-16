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
    Trello.logger.info "Connected with #{db_environment} db env."
    Trello.logger.info "Processing #{notifications.size} tracking notifications (from #{oldest} to #{latest}) starting from #{from_date}..."

    notifications.each do |notification|
      tracking = Tracking.new(notification)
      begin
        existing_card = TrackedCard.with_trello_id(tracking.card.trello_id)
        Trello.logger.debug "tracked card found: #{existing_card.first.name} with trello_id:#{existing_card.first.id}" if existing_card.first
        card = existing_card.first || tracking.card
        if tracking.estimate?
          card.estimates << tracking.estimate
        elsif tracking.effort?
          card.efforts << tracking.effort
        end
        card.save
        Trello.logger.info "[#{tracking.date}] From #{tracking.notifier.username.color(:green)}\t on card '#{tracking.card.name.color(:yellow)}': #{tracking.send(:raw_tracking)}"

      rescue StandardError => e
        Trello.logger.error "skipping tracking: #{e.message}".color(:red)
        Trello.logger.error "#{e.backtrace}".color(:red)
      end
    end
    Trello.logger.info "Done tracking cards!".color(:green)
    TrackedCard.all.each { |tracked_card| Trello.logger.info(tracked_card.to_s.color(:yellow)) }
  end

  def tracker
    @tracker ||= Member.find(tracker_username)
  end

  private

  def boundary_dates_in(notifications)
    dates = notifications.map {|n| Chronic.parse(n.date)}
    [dates.min, dates.max]
  end
end
