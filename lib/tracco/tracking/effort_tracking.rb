module Tracco
  module Tracking
    class EffortTracking
      include Base

      def add_to(card)
        card.efforts << effort unless card.contains_effort?(effort)
      end

      def effort
        @effort ||= Effort.new(amount: total_effort_from(raw_effort), date: date, members: effort_members, tracking_notification_id: tracking_notification.id)
      end

      private

      def total_effort_from(raw_effort)
        effort_amount = convert_to_hours(raw_effort)
        total_effort = effort_amount * effort_members.size
      end

      def raw_effort
        extract_match_from_raw_tracking(/\+#{DURATION_REGEXP}/)
      end

      def effort_members
        @effort_members ||= members_involved_in_the_effort.map do |username|
          Member.build_from(Trello::Member.find(username))
        end
      end

      def members_involved_in_the_effort
        members_involved_in_the_effort = raw_tracking.scan(/@(\w+)/).flatten
        members_involved_in_the_effort << notifier.username unless should_count_only_listed_members?

        members_involved_in_the_effort
      end

      def should_count_only_listed_members?
        raw_tracking =~ /\((@\w+\W*\s*)+\)/
      end

    end
  end

end
