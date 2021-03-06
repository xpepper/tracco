require 'set'

module Tracco
  class Effort
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::MultiParameterAttributes

    field :amount,  type: BigDecimal
    field :date,    type: Date
    field :tracking_notification_id
    field :muted,   type: Boolean, default: false

    embeds_many :members
    embedded_in :tracked_card

    default_scope where(muted: false).asc(:date)

    validates_presence_of :amount, :date, :members

    def amount_per_member
      amount / members.size
    end

    def include?(member)
      members.include?(member)
    end

    def ==(other)
      return true if other.equal?(self)
      return false unless other.kind_of?(self.class)

      amount == other.amount && date == other.date && Set.new(members) == Set.new(other.members)
    end

    def to_s
      "[#{date}] spent #{amount} hours by #{members.map(&:at_username).join(", ")}"
    end

  end

end
