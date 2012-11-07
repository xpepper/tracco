class TrelloTracker
  include TrelloConfiguration
  include TrelloAuthorize
  include Trello

  trap("SIGINT") { exit! }

  def initialize(custom_auth_params = {})
    auth_params = configuration["trello"].merge(custom_auth_params)
    init_trello(auth_params)
  end

  def track(from_date=Date.parse("2000-01-01"))
    notifications = tracker.notifications.select &greater_than_or_equal_to(from_date)
    puts "Processing #{notifications.size} tracking notifications..."

    notifications.each do |notification|
      tracking = Tracking.new(notification)
      begin
        card = cards.find { |each| each.id == tracking.card.id } || tracking.card
        if tracking.estimate?
          card.estimates << tracking.estimate
        elsif tracking.effort?
          card.efforts << tracking.effort
        end
        cards << card unless cards.map(&:id).include?(card.id)
        puts "[#{tracking.date}] From #{tracking.notifier.username.color(:green)}\t on card '#{tracking.card.name.color(:yellow)}': #{tracking.send(:raw_tracking)}"
      rescue StandardError => e
        puts "skipping tracking: #{e.message}".color(:red)
      end
    end
    puts "Tracked #{cards.size} cards."
    cards.each do |c|
      puts c.to_s
    end
  end

  def cards
    @cards ||= Set.new
  end

  def tracker
    @tracker ||= Member.find(tracker_username)
  end

  private

  def greater_than_or_equal_to(from_date)
    lambda { |each_notification| Chronic.parse(each_notification.date) >= from_date }
  end

end
