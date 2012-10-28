require 'trello'
require 'rainbow'
require 'set'

require_relative 'trello_authorize'
require_relative 'tracking'

module Trello
  class Card
    def estimates
      @estimates ||= []
    end
    def efforts
      @estimates ||= []
    end
  end
end

class TrelloTracker
  include TrelloAuthorize
  include Trello

  def initialize
    init_trello
  end
  
  def cards
    @cards ||= Set.new
  end

  def track
    tracker = Member.find(tracking_username)
    tracker.notifications.each do |notification|
      tracking = Tracking.new(notification)
      begin
        card = tracking.card      
        if tracking.estimate?
          card.estimates << tracking.estimate
        elsif tracking.effort?
          card.efforts << tracking.effort
        end
        cards << card

        puts "[#{tracking.date}] From #{tracking.notifier.username.color(:green)}\t on card '#{tracking.card.name.color(:yellow)}': #{tracking.send(:raw_tracking)}"
      rescue => e
        puts "skipping tracking: #{e.message}".color(:red)
      end
    end

  end

end