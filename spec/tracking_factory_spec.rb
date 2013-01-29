require 'spec_helper'

describe TrackingFactory do

  TIME_MEASUREMENTS = {
    hours:    'h',
    days:     'd',
    giorni:   'g',
    pomodori: 'p'
  }

  context "unknown tracking format" do
    it "builds an invalid tracking instance" do
      TrackingFactory.build_from(unrecognized_notification).class.should == Tracking::InvalidTracking

      with_message("@trackinguser +30m") { |tracking| tracking.class.should == Tracking::InvalidTracking }
    end
  end

  TIME_MEASUREMENTS.each_key do |time_measurement|

    context "estimate tracking notification in #{time_measurement}" do
      it "builds an estimate tracking instance" do
        TrackingFactory.build_from(create_estimate(time_measurement)).class.should == Tracking::EstimateTracking
      end
    end

    context "effort tracking notification in #{time_measurement}" do
      it "builds an effort tracking instance" do
        TrackingFactory.build_from(create_effort(time_measurement)).class.should == Tracking::EffortTracking
      end
    end

  end

  context "card done tracking notification" do
    it "builds a card done tracking instance" do
      with_message("@trackinguser DONE") { |tracking| tracking.class.should == Tracking::CardDoneTracking }
    end
  end

end
