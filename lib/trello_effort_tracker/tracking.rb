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

  def date
    Chronic.parse(date_as_string).to_date
  end

  def card_done?
    raw_tracking =~ /DONE/
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

  def unknown_format?
    !estimate? && !effort?
  end

  def to_s
    "[#{date}] From #{notifier.username.color(:green)}\t on card '#{trello_card.name.color(:yellow)}': #{raw_text}"
  end

  private

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

  def raw_tracking
    raw_text.gsub("@#{tracker_username}", "")
  end

  def raw_text
    @tracking_notification.data['text']
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

