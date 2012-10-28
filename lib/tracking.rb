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
    estimate_to_parse = raw_estimate
    return if estimate_to_parse.nil?

    time_scale = estimate_to_parse.slice!(-1)
    converter = TIME_CONVERTERS[time_scale]
    converter.call(Float(estimate_to_parse))
  end

  def effort?

  end

  def effort

  end

  private

  def raw_tracking
    @tracking_notification.data['text'].gsub("@#{tracking_username}", "")
  end

  def raw_estimate
    estimate_from_notification = nil
    raw_tracking.scan(/\[(\d+\.?\d*[phdg])\]/) do |match|
      estimate_from_notification = match.first
    end
    
    estimate_from_notification
  end
end

