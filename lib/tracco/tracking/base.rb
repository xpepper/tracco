module Tracco
  module Tracking
    module Base
      extend Forwardable

      TIME_CONVERTERS = {
        'h' => lambda { |estimate| estimate },
        'd' => lambda { |estimate| estimate * 8 },
        'g' => lambda { |estimate| estimate * 8 },
        'p' => lambda { |estimate| estimate / 2  }
      }

      DURATION_REGEXP = '(\d+\.?\d*[phdg])'
      DATE_REGEXP = /(\d{2})\.(\d{2})\.(\d{4})/

      # delegate to the trello notification the member_creator method aliased as 'notifier'
      def_delegator :@tracking_notification, :member_creator, :notifier

      def initialize(tracking_notification)
        @tracking_notification = tracking_notification
      end

      def date
        Chronic.parse(date_as_string).to_date
      end

      def to_s
        "[#{date}] From #{notifier.username.color(:green)}\t on card '#{trello_card.name.color(:yellow)}': #{tracking_message}"
      end

      private

      def tracking_notification
        @tracking_notification
      end

      def trello_card
        @trello_card ||= tracking_notification.card
      end

      def notification_date
        Chronic.parse(tracking_notification.date).to_date
      end

      def raw_tracking
        @raw_tracking ||= remove_tracker_from(tracking_message)
      end

      def remove_tracker_from(tracking_message)
        tracking_message.sub(/^\s*@\w+\s/, "")
      end

      def tracking_message
        tracking_notification.data['text']
      end

      def convert_to_hours(duration_as_string)
        return if duration_as_string.nil?

        time_scale = duration_as_string.slice!(-1)
        converter = TIME_CONVERTERS[time_scale]
        converter.call(Float(duration_as_string))
      end

      def date_as_string
        case raw_tracking
        when DATE_REGEXP
          day, month, year = raw_tracking.scan(DATE_REGEXP).flatten
          "#{year}-#{month}-#{day}"
        when /yesterday\s+\+#{DURATION_REGEXP}/, /\+#{DURATION_REGEXP}\s+yesterday/
            (notification_date - 1).to_s
        else
          tracking_notification.date
        end
      end

      def extract_match_from_raw_tracking(regexp)
        extracted = nil
        raw_tracking.scan(regexp) do |match|
          extracted = match.first
        end

        extracted
      end
    end
  end

end
