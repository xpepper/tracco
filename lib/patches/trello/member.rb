module Trello

  class Member
    def notifications_from(from_date)
      notifications(limit:1000).select &greater_than_or_equal_to(from_date)
    end
    
    private

    def greater_than_or_equal_to(from_date)
      lambda { |notification| Chronic.parse(notification.date) >= from_date }
    end
    
  end

end
