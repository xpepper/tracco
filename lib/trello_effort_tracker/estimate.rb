class Estimate
  include Mongoid::Document
  include Mongoid::Timestamps

  field :amount,  type: BigDecimal
  field :date,    type: Date
  field :tracking_notification_id

  embedded_in :tracked_card

  validates_presence_of :amount, :date

  def ==(other)
    return true if other.equal?(self)
    return false unless other.kind_of?(self.class)

    amount == other.amount && date == other.date
  end

  def to_s
    "[#{date}] estimated #{amount} hours"
  end
end