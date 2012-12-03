class TrackedCard
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :description
  field :short_id,    type: Integer
  field :trello_id
  field :due,         type: Date
  field :closed,      type: Boolean
  field :url
  field :pos

  embeds_many :estimates
  embeds_many :efforts

  validates_presence_of :name, :short_id, :trello_id
  validates_numericality_of :short_id

  scope :all_by_trello_id, ->(a_trello_id) { where(trello_id: a_trello_id) }

  def self.with_trello_id(trello_id)
    all_by_trello_id(trello_id).first
  end

  def self.build_from(trello_card)
    new(trello_card.attributes.merge(trello_id: trello_card.id))
  end

  def add(tracking)
    if tracking.estimate? && estimates.none? {|e| e.tracking_notification_id == tracking.estimate.tracking_notification_id}
      estimates << tracking.estimate
    elsif tracking.effort? && efforts.none? {|e| e.tracking_notification_id == tracking.effort.tracking_notification_id}
      efforts << tracking.effort
    else
      Trello.logger.warn "Ignoring tracking notification: #{tracking}" if tracking.unknown_format?
    end
  end

  def total_effort
    efforts.map(&:amount).inject(0, &:+)
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
