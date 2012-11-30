class Tracking
  extend Forwardable
  include TrelloConfiguration

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

  def card
    @card ||= TrackedCard.build_from(trello_card)
  end

  def date
    Chronic.parse(date_as_string).to_date
  end

  def estimate?
    !raw_estimate.nil?
  end

  def estimate
    estimate = convert_to_hours(raw_estimate)
    Estimate.new(amount: estimate, date: date, tracking_notification_id: @tracking_notification.id) if estimate
  end

  def effort?
    !raw_effort.nil?
  end

  def effort
    effort_amount = convert_to_hours(raw_effort)
    if effort_amount
      total_effort = effort_amount * effort_members.size
      Effort.new(amount: total_effort, date: date, members: effort_members, tracking_notification_id: @tracking_notification.id)
    end
  end

  def effort_members
    effort_members = raw_tracking.scan(/(@\w+)/).flatten
    effort_members << notifier_username unless should_count_only_listed_members?

    effort_members
  end

  private

  def should_count_only_listed_members?
    raw_tracking =~ /\((@\w+\W*\s*)+\)/
  end

  def notifier_username
    "@#{notifier.username}"
  end

  def raw_tracking
    @tracking_notification.data['text'].gsub("@#{tracker_username}", "")
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

  def date_as_string
    case raw_tracking
    when DATE_REGEXP
      day, month, year = raw_tracking.scan(DATE_REGEXP).flatten
      "#{year}-#{month}-#{day}"
    when /yesterday\s+\+#{DURATION_REGEXP}/, /\+#{DURATION_REGEXP}\s+yesterday/
      (notification_date - 1).to_s
    else
      @tracking_notification.date
    end
  end

  def extract_match_from_raw_tracking(regexp)
    extracted = nil
    raw_tracking.scan(regexp) do |match|
      extracted = match.first
    end

    extracted
  end

  def trello_card
    @trello_card ||= @tracking_notification.card
  end

  def notification_date
    Chronic.parse(@tracking_notification.date).to_date
  end

end

