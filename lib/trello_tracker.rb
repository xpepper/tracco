require 'trello'
require 'rainbow'

require_relative 'trello_authorize'
require_relative 'tracking'

class TrelloTracker
  include TrelloAuthorize
  include Trello

  def initialize
    init_trello
  end

  def track
    tracker = Member.find(tracking_username)
    tracker.notifications.each do |notification|
      tracking = Tracking.new(notification)
      begin
        puts "[#{tracking.date}] From #{tracking.notifier.username.color(:green)} on card '#{tracking.card.name.color(:yellow)}': #{tracking.raw_text}"
      rescue => e
        puts "skipping tracking: #{e.message}".color(:red)
      end
    end

  end

end