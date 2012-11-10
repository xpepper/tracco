class Effort
  include Mongoid::Document
  include Mongoid::Timestamps

  field :amount,  type: BigDecimal
  field :date,    type: Date
  field :members, type: Array

  embedded_in :tracked_card

  #TODO ha senso avere una uguaglianza tra effort?
  def ==(other)
    return true if other.equal?(self)
    return false unless other.kind_of?(self.class)

    # TODO includere members nella equals
    amount == other.amount && date == other.date # && @members == other.members
  end

  def to_s
    "[#{date}] spent #{amount} hours by #{members.join(", ")}"
  end

end