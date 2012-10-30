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
    @amount == other.amount && @date == other.date
    # TODO aggiungere members
  end

  def to_s
    # TODO aggiungere members
    "[#{date}] spent #{amount} hours"
  end
  
end