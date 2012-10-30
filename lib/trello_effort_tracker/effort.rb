class Effort
  
  attr_reader :amount, :date
  
  def initialize(effort_in_hours, date)
    @amount = effort_in_hours
    @date = date
    # @members = members
  end
  
  def ==(other)
    return true if other.equal?(self)
    return false unless other.kind_of?(self.class) 
    @amount == other.amount && @date == other.date
  end

  def to_s
    "[#{date}] spent #{amount} hours"
  end
  
end