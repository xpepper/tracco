class Effort
  
  attr_reader :amount, :date, :members
  
  def initialize(effort_in_hours, date, members)
    @amount = effort_in_hours
    @date = date
    @members = members
  end
  
  def ==(other)
    return true if other.equal?(self)
    return false unless other.kind_of?(self.class) 

    # TODO includere members nella equals
    @amount == other.amount && @date == other.date # && @members == other.members
  end

  def to_s
    "[#{date}] spent #{amount} hours by #{members.join(", ")}"
  end
  
end