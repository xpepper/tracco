# Reopening the Trello::Member class to add some helper methods
module Trello
  class Member

    # Fetch all the direct notifications sent to the 'tracking user' starting from a given date
    def tracking_notifications_since(starting_date)
      notifications(limit:1000).select(&greater_than_or_equal_to(starting_date)).select(&tracking_notification?)
    end

    private

    def greater_than_or_equal_to(starting_date)
      lambda { |notification| Chronic.parse(notification.date) >= starting_date }
    end

    def tracking_notification?
      lambda { |notification| notification.type == "mentionedOnCard" }
    end

  end

end
