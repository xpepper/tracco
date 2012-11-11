require 'spec_helper'
require 'mongoid-rspec'

describe Effort do

  it { should have_fields(:amount, :date, :members) }
  it { should be_embedded_in(:tracked_card) }

  describe "validation" do
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:members) }
  end

  describe "equality" do

    it "is equal to another effort with same amount, date and members" do
      effort          = Effort.new(amount: 3, date: Date.parse("2012-11-09"), members: %w{@piero @tommaso})
      same_effort     = Effort.new(amount: 3, date: Date.parse("2012-11-09"), members: %w{@piero @tommaso})
      yet_same_effort = Effort.new(amount: 3, date: Date.parse("2012-11-09"), members: %w{@tommaso @piero})

      effort.should == same_effort
      effort.should == yet_same_effort
    end

    it "is not equal when amount differs" do
      effort          = Effort.new(amount: 3, date: Date.today, members: %w{@piero @tommaso})
      another_effort  = Effort.new(amount: 1, date: Date.today, members: %w{@piero @tommaso})

      effort.should_not == another_effort
    end

    it "is not equal when date differs" do
      effort          = Effort.new(amount: 3, date: Date.parse("2012-11-09"), members: %w{@piero @tommaso})
      another_effort  = Effort.new(amount: 3, date: Date.parse("2011-10-08"), members: %w{@piero @tommaso})

      effort.should_not == another_effort
    end

    it "is not equal when members differ" do
      effort              = Effort.new(amount: 3, date: Date.today, members: %w{@piero @tommaso})
      another_effort      = Effort.new(amount: 3, date: Date.today, members: %w{@piero @alessandro})

      effort.should_not == another_effort
    end

  end
end
