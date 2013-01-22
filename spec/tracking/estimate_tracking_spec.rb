require 'spec_helper'

module Tracking
  describe EstimateTracking do

    describe "#estimate" do

      it "is nil when the notification does not contain an estimate" do
        TrackingFactory.build_from(unrecognized_notification).estimate.should be_nil
      end

      it "is the hour-based estimate when the notification contains an estimate in hours" do
        raw_data = create_notification(data: { 'text' => "@trackinguser [2h]" }, date: "2012-10-28T21:06:14.801Z")

        TrackingFactory.build_from(raw_data).estimate.should == Estimate.new(amount: 2.0, date: Date.parse('2012-10-28'))
      end

      it "converts the estimate in hours when the notification contains an estimate in days" do
        TrackingFactory.build_from(create_notification(data: { 'text' => "@trackinguser [1.5d]" })).estimate.amount.should == 8+4
        TrackingFactory.build_from(create_notification(data: { 'text' => "@trackinguser [1.5g]" })).estimate.amount.should == 8+4
      end

      it "converts the estimate in hours when the notification contains an estimate in pomodori" do
        raw_data = create_notification(data: { 'text' => "@trackinguser [10p]" })
        TrackingFactory.build_from(raw_data).estimate.amount.should == 5
      end

      it "fetch the estimate from a complex estimate message" do
        raw_data = create_notification(data: { 'text' => "@maxmazza Dobbiamo ancora lavorarci.\n@trackinguser ristimo ancora [3h] per il fix" })
        TrackingFactory.build_from(raw_data).estimate.amount.should == 3.0
      end

      it "tracks the effort with the date given in the notification text, not the actual notification date" do
        raw_data = create_notification( data: { 'text' => "@trackinguser 22.11.2012 [6p]" }, date: "2012-09-19T12:46:13.713Z")

        tracking = TrackingFactory.build_from(raw_data)

        tracking.estimate.date.should == Date.parse('2012-11-22')
      end

    end
  end

end
