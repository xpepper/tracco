require 'chronic'
require 'forwardable'

class Tracking
  extend Forwardable
  include TrelloAuthorize

  TIME_CONVERTERS = {
    'h' => lambda { |estimate| estimate },
    'd' => lambda { |estimate| estimate * 8 },
    'g' => lambda { |estimate| estimate * 8 },
    'p' => lambda { |estimate| estimate / 2  }
  }

  DURATION_REGEXP = '(\d+\.?\d*[phdg])'

  def_delegator :@tracking_notification, :card
  def_delegator :@tracking_notification, :member_creator, :notifier

  def initialize(tracking_notification)
    @tracking_notification = tracking_notification
  end

  def date
    Chronic.parse(@tracking_notification.date)
  end

  def estimate?
    !raw_estimate.nil?
  end

  def estimate
    estimate = convert_to_hours(raw_estimate)
    Estimate.new(estimate, date) if estimate
  end

  def effort?
    !raw_effort.nil?
  end

  def effort
    effort = convert_to_hours(raw_effort)
    Effort.new(effort * effort_members.size, date, effort_members) if effort
  end

  def effort_members
    other_effort_members = raw_tracking.scan(/(@\w+)/).flatten
    other_effort_members << notifier_username
  end

  def find_in(cards)
    cards.detect { |each_card| each_card.id == self.card.id }
  end

  private

  def notifier_username
    "@#{notifier.username}"
  end

  def raw_tracking
    @tracking_notification.data['text'].gsub("@#{tracking_username}", "")
  end

  def raw_estimate
    extract_match_from_raw_tracking(/\[#{DURATION_REGEXP}\]/)
  end

  def raw_effort
    extract_match_from_raw_tracking(/\+#{DURATION_REGEXP}/)
  end

  def convert_to_hours(duration_as_string)
    return if duration_as_string.nil?

    time_scale = duration_as_string.slice!(-1)
    converter = TIME_CONVERTERS[time_scale]
    converter.call(Float(duration_as_string))
  end

  def extract_match_from_raw_tracking(regexp)
    extracted = nil
    raw_tracking.scan(regexp) do |match|
      extracted = match.first
    end

    extracted
  end

end

