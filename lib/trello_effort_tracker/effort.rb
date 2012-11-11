class Effort
  include Mongoid::Document
  include Mongoid::Timestamps

  field :amount,  type: BigDecimal
  field :date,    type: Date
  field :members, type: Array

  embedded_in :tracked_card

  validates_presence_of :amount, :date, :members

  def ==(other)
    return true if other.equal?(self)
    return false unless other.kind_of?(self.class)

    amount == other.amount && date == other.date && Set.new(members) == Set.new(other.members)
  end

  def to_s
    "[#{date}] spent #{amount} hours by #{members.join(", ")}"
  end

end