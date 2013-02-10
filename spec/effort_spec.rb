require 'spec_helper'
require 'mongoid-rspec'

describe Effort do

  it { should have_fields(:amount, :date) }
  it { should be_embedded_in(:tracked_card) }
  it { should embed_many(:members) }

  describe "validation" do
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:members) }
  end

  %w{piero tommaso tom ugo}.each do |username|
    let(username.to_sym) { Member.new(username: username) }
  end

  describe "#amount_per_member" do
    it "counts the amount spent per single member" do
      effort = Effort.new(amount: 6, members: [piero, tommaso], date: Date.parse("2012-11-09"), )
      effort.amount_per_member.should == 3
    end
  end

  describe "equality" do
    it "is equal to another effort with same amount, date and members" do
      effort          = Effort.new(amount: 3, date: Date.parse("2012-11-09"), members: [piero, tommaso])
      same_effort     = Effort.new(amount: 3, date: Date.parse("2012-11-09"), members: [piero, tommaso])
      yet_same_effort = Effort.new(amount: 3, date: Date.parse("2012-11-09"), members: [tommaso, piero])

      effort.should == same_effort
      effort.should == yet_same_effort
    end

    it "is not equal when amount differs" do
      effort          = Effort.new(amount: 3, date: Date.today, members: [tom, ugo])
      another_effort  = Effort.new(amount: 1, date: Date.today, members: [tom, ugo])

      effort.should_not == another_effort
    end

    it "is not equal when date differs" do
      effort          = Effort.new(amount: 3, date: Date.parse("2012-11-09"), members: [tom, ugo])
      another_effort  = Effort.new(amount: 3, date: Date.parse("2011-10-08"), members: [tom, ugo])

      effort.should_not == another_effort
    end

    it "is not equal when members differ" do
      effort         = Effort.new(amount: 3, date: Date.today, members: [tom, ugo])
      another_effort = Effort.new(amount: 3, date: Date.today, members: [piero, ugo])

      effort.should_not == another_effort
    end

  end
end
