module Trello
  class Member
    # Reopening the Trello::Member class to add a notifications helper method
    def notifications_since(starting_date)
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
