require 'spec_helper'
require 'mongoid-rspec'

module Tracco
  describe Estimate do

    it { should have_fields(:amount, :date) }
    it { should be_embedded_in(:tracked_card) }

    describe "validation" do
      it { should validate_presence_of(:amount) }
      it { should validate_presence_of(:date) }
    end

    describe "equality" do

      it "is equal to another estimate with same amount and date" do
        estimate          = Estimate.new(amount: 3, date: Date.parse("2012-11-09"))
        same_estimate     = Estimate.new(amount: 3, date: Date.parse("2012-11-09"))

        estimate.should == same_estimate
      end

      it "is not equal when amount differs" do
        estimate          = Estimate.new(amount: 3, date: Date.today)
        another_estimate  = Estimate.new(amount: 1, date: Date.today)

        estimate.should_not == another_estimate
      end

      it "is not equal when date differs" do
        estimate          = Estimate.new(amount: 3, date: Date.parse("2012-11-09"))
        another_estimate  = Estimate.new(amount: 3, date: Date.parse("2011-10-08"))

        estimate.should_not == another_estimate
      end

    end
  end
end
