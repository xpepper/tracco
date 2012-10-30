class Estimate
  
  attr_reader :amount, :date
  
  def initialize(estimate_in_hours, date)
    @amount = estimate_in_hours
    @date = date
  end
  
  def ==(other)
    return true if other.equal?(self)
    return false unless other.kind_of?(self.class) 
    @amount == other.amount && @date == other.date
  end
  
  def to_s
    "[#{date}] estimated #{amount} hours"
  end
end