require 'spec_helper'

describe Trello::Card do

  subject(:card) { Trello::Card.new }

  it "has no estimates not efforts initially" do
    card.estimates.should be_empty
    card.efforts.should be_empty
  end
  
  it "is possible to add estimates" do
    card.estimates << Estimate.new(5, Date.today.prev_day)
    card.estimates << Estimate.new(12, Date.today)
    
    card.estimates.should have(2).estimates    
  end

  it "is possible to add efforts" do
    card.efforts << Effort.new(3, Date.today, %w{@piero @tommaso})
    card.efforts << Effort.new(5, Date.today, %w{@tommaso})
    
    card.efforts.should have(2).efforts
  end
  
  describe "#total_effort" do
    it "is zero when there's no effort" do
      card.total_effort.should == 0
    end    
    
    it "computes the total effort on the card" do
      card.efforts << Effort.new(3, Date.today, %w{@piero @tommaso})
      card.efforts << Effort.new(5, Date.today, %w{@tommaso})

      card.total_effort.should == 3+5
    end    
  end
  
  describe "#to_s" do
    it "describes the card as a string" do
      card = Trello::Card.new('name' => "A Story Name")
      card.estimates << Estimate.new(5, Date.today)
      card.efforts << Effort.new(3, Date.today, %w{@piero @tommaso})
      card.efforts << Effort.new(6, Date.today, %w{@piero @tommaso})
      
      card.to_s.should == "[A Story Name]. Total effort: 9h. Estimates [[2012-11-07] estimated 5 hours]. " \
                          "Efforts: [[2012-11-07] spent 3 hours by @piero, @tommaso, [2012-11-07] spent 6 hours by @piero, @tommaso]"
      
    end    
  end
  
end