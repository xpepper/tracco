class TrackedCard
  include Mongoid::Document
  include Mongoid::Timestamps
  extend MongoidHelper

  field :name
  field :description
  field :short_id,    type: Integer
  field :trello_id
  field :done,        type: Boolean
  field :due,         type: Date
  field :closed,      type: Boolean
  field :url
  field :pos

  embeds_many :estimates
  embeds_many :efforts

  validates_presence_of :name, :short_id, :trello_id
  validates_numericality_of :short_id

  def self.find_by_trello_id(trello_id)
    without_mongo_raising_errors do
      find_by(trello_id: trello_id)
    end
  end

  def self.update_or_create_with(trello_card)
    tracked_card = TrackedCard.find_or_create_by(trello_id: trello_card.id)
    trello_card.attributes.delete(:id)
    updated_successfully = tracked_card.update_attributes(trello_card.attributes)
    return tracked_card if updated_successfully
  end

  def self.build_from(trello_card)
    trello_card_id = trello_card.id
    trello_card.attributes.delete(:id)
    new(trello_card.attributes.merge(trello_id: trello_card_id))
  end

  def add(tracking)
    if tracking.estimate? && estimates.none? {|e| e.tracking_notification_id == tracking.estimate.tracking_notification_id}
      estimates << tracking.estimate
    elsif tracking.effort? && efforts.none? {|e| e.tracking_notification_id == tracking.effort.tracking_notification_id}
      efforts << tracking.effort
    elsif tracking.card_done?
      self.done = true
    else
      Trello.logger.warn "Ignoring tracking notification: #{tracking}" if tracking.unknown_format?
    end
  end

  def no_tracking?
    first_activity_date.nil?
  end

  def first_activity_date
    [working_start_date, first_estimate_date].compact.min
  end

  def working_start_date
    efforts.sort_by(&:date).first.date if efforts.present?
  end

  def first_estimate_date
    estimates.sort_by(&:date).first.date if estimates.present?
  end

  def last_estimate_date
    estimates.sort_by(&:date).last.date if estimates.present?
  end

  def total_effort
    efforts.map(&:amount).inject(0, &:+)
  end

  def members
    efforts.map(&:members).flatten.uniq
  end

  def last_estimate_error
    estimate_errors.last
  end

  def estimate_errors
    return [] if estimates.empty? || efforts.empty?

    estimate_errors = []
    estimates.each do |each|
      estimate_errors << (100 * ((total_effort - each.amount) / each.amount * 1.0)).round(2)
    end

    estimate_errors
  end

  def to_s
    "[#{name}]. Total effort: #{total_effort}h. Estimates #{estimates.map(&:to_s)}. Efforts: #{efforts.map(&:to_s)}"
  end

  def ==(other)
    return true if other.equal?(self)
    return false unless other.kind_of?(self.class)
    trello_id == other.trello_id
  end

end
