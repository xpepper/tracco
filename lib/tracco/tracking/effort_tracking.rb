module Tracking
  class EffortTracking
    include Base

    #TODO: rename to 'amount' ?
    #TODO: avoid recomputing effort every time using a lazy instance variable
    def effort
      effort_amount = convert_to_hours(raw_effort)
      if effort_amount
        total_effort = effort_amount * effort_members.size
        Effort.new(amount: total_effort, date: date, members: effort_members, tracking_notification_id: tracking_notification.id)
      end
    end

    def add_to(card)
      card.efforts << effort unless card.contains_effort?(effort)
    end

    private

    def raw_effort
      extract_match_from_raw_tracking(/\+#{DURATION_REGEXP}/)
    end

    def effort_members
      @effort_members ||= users_involved_in_the_effort.map do |username|
        Member.build_from(Trello::Member.find(username))
      end

      @effort_members
    end

    def users_involved_in_the_effort
      users_involved_in_the_effort = raw_tracking.scan(/@(\w+)/).flatten
      users_involved_in_the_effort << notifier.username unless should_count_only_listed_members?

      users_involved_in_the_effort
    end

    def should_count_only_listed_members?
      raw_tracking =~ /\((@\w+\W*\s*)+\)/
    end

  end
end
