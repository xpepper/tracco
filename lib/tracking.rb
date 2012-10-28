require 'chronic'
require 'forwardable'
require 'active_support/all'

class Tracking
  extend Forwardable
  include TrelloAuthorize

  def_delegator :@tracking_notification, :card
  def_delegator :@tracking_notification, :member_creator, :notifier

  def initialize(tracking_notification)
    @tracking_notification = tracking_notification
  end

  def date
    Chronic.parse(@tracking_notification.date)
  end

  def raw_text
    @tracking_notification.data['text'].gsub("@#{tracking_username}", "")
  end

  def estimate?
    raw_text =~ /\[(\d+\.?\d*[phdg])\]/
  end
  
  def estimate
    if estimate?
      raw_text =~ /\[(\d+\.?\d*[phdg])\]/
      $1.chop.to_i.hours
    end
  end

  def effort?

  end
  
  def effort

  end
end

