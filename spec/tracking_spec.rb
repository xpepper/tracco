require 'spec_helper'
require 'date'

describe Tracking do

  TIME_MEASUREMENTS = {
    hours:    'h',
    days:     'd',
    giorni:   'g',
    pomodori: 'p'
  }

  describe "#estimate?" do
    let(:unrecognized_notification) { stub(data: { 'text' => '@trackinguser hi there!' }) }

    it "is false when the notification does not contain an estimate" do
      Tracking.new(unrecognized_notification).estimate?.should be_false
    end

    TIME_MEASUREMENTS.each_key do |time_measurement|
      it "is true when the notification contains an estimate in #{time_measurement}" do
        tracking_estimate = Tracking.new(create_estimate(time_measurement))

        tracking_estimate.estimate?.should be_true
        tracking_estimate.effort?.should be_false
      end
    end

  end

  describe "#estimate" do

    let(:unrecognized_notification) { stub(data: { 'text' => '@trackinguser hi there!' }).as_null_object }

    it "is nil when the notification does not contain an estimate" do
      Tracking.new(unrecognized_notification).estimate.should be_nil
    end

    it "is the hour-based estimate when the notification contains an estimate in hours" do
      raw_data = stub(data: { 'text' => "@trackinguser [2h]" }, date: "2012-10-28T21:06:14.801Z")

      Tracking.new(raw_data).estimate.should == Estimate.new(2.0, Time.parse('2012-10-28 21:06:14.801 UTC'))
    end

    it "converts the estimate in hours when the notification contains an estimate in days" do
      Tracking.new(stub(data: { 'text' => "@trackinguser [1.5d]" }).as_null_object).estimate.amount.should == 8+4
      Tracking.new(stub(data: { 'text' => "@trackinguser [1.5g]" }).as_null_object).estimate.amount.should == 8+4
    end

    it "converts the estimate in hours when the notification contains an estimate in pomodori" do
      raw_data = stub(data: { 'text' => "@trackinguser [10p]" }).as_null_object
      Tracking.new(raw_data).estimate.amount.should == 5
    end

    it "fetch the estimate from a complex estimate message" do
      raw_data = stub(data: { 'text' => "@maxmazza Dobbiamo ancora lavorarci.\n@trackinguser ristimo ancora [3h] per il fix" }).as_null_object
      Tracking.new(raw_data).estimate.amount.should == 3.0
    end

  end

  describe "#effort?" do
    let(:unrecognized_notification) { stub(data: { 'text' => '@trackinguser hi there!' }).as_null_object }

    it "is false when the notification does not contain an estimate" do
      Tracking.new(unrecognized_notification).effort?.should be_false
    end

    TIME_MEASUREMENTS.each_key do |time_measurement|
      it "is true when the notification contains an estimate in #{time_measurement}" do
        tracking_effort = Tracking.new(create_effort(time_measurement))

        tracking_effort.effort?.should be_true
        tracking_effort.estimate?.should be_false
      end
    end
  end

  describe "#effort" do
    let(:unrecognized_notification) { stub(data: { 'text' => '@trackinguser hi there!' }).as_null_object }

    it "is nil when the notification does not contain an estimate" do
      Tracking.new(unrecognized_notification).effort.should be_nil
    end

    it "is the hour-based effort when the notification contains an effort in hours" do
      raw_data = stub(data: { 'text' => "@trackinguser +2h" }, date: "2012-10-28T21:06:14.801Z")

      # TODO TEST FOR MEMBERS TOO!
      Tracking.new(raw_data).effort.should == Effort.new(2.0, Time.parse('2012-10-28 21:06:14.801 UTC'), ["any"])
    end

    it "converts the effort in hours when the notification contains an effort in days" do
      Tracking.new(stub(data: { 'text' => "@trackinguser +1.5d" }).as_null_object).effort.amount.should == 8+4
      Tracking.new(stub(data: { 'text' => "@trackinguser +1.5g" }).as_null_object).effort.amount.should == 8+4
    end

    it "converts the effort in hours when the notification contains an effort in pomodori" do
      raw_data = stub(data: { 'text' => "@trackinguser +10p" }).as_null_object
      Tracking.new(raw_data).effort.amount.should == 5
    end

    it "fetch the effort from a complex effort message" do
      raw_data = stub(data: { 'text' => "@trackinguser ho speso +2h e spero che stavolta possiamo rilasciarla" }).as_null_object
      Tracking.new(raw_data).effort.amount.should == 2.0
    end

    it "computes the effort considering all the mentioned team mates in the message" do
      raw_data = stub(data: { 'text' => "@trackinguser +2h assieme a @michelepangrazzi e @alessandrodescovi" }).as_null_object
      Tracking.new(raw_data).effort.amount.should == 2.0 * 3
    end

    it "tracks all the team mates which spent that effort on the card" do
      raw_data = stub(data: { 'text' => "@trackinguser +2h assieme a @michelepangrazzi e @alessandrodescovi" }).as_null_object
      Tracking.new(raw_data).effort.members.should == ["@michelepangrazzi", "@alessandrodescovi"]
    end


  end



  def create_estimate(time_measurement)
    stub(data: { 'text' => "@trackinguser [1.5#{TIME_MEASUREMENTS[time_measurement]}]" }).as_null_object
  end

  def create_effort(time_measurement)
    stub(data: { 'text' => "@trackinguser +4.5#{TIME_MEASUREMENTS[time_measurement]}]" }).as_null_object
  end

end
