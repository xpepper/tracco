require 'spec_helper'

describe Tracking do

  TIME_MEASUREMENTS = {
    hours:    'h',
    days:     'd',
    giorni:   'g',
    pomodori: 'p'
  }

  let(:unrecognized_notification) { create_notification(data: { 'text' => '@trackinguser hi there!' }) }

  describe "#estimate?" do

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

    it "is nil when the notification does not contain an estimate" do
      Tracking.new(unrecognized_notification).estimate.should be_nil
    end

    it "is the hour-based estimate when the notification contains an estimate in hours" do
      raw_data = create_notification(data: { 'text' => "@trackinguser [2h]" }, date: "2012-10-28T21:06:14.801Z")

      Tracking.new(raw_data).estimate.should == Estimate.new(amount: 2.0, date: Date.parse('2012-10-28'))
    end

    it "converts the estimate in hours when the notification contains an estimate in days" do
      Tracking.new(create_notification(data: { 'text' => "@trackinguser [1.5d]" })).estimate.amount.should == 8+4
      Tracking.new(create_notification(data: { 'text' => "@trackinguser [1.5g]" })).estimate.amount.should == 8+4
    end

    it "converts the estimate in hours when the notification contains an estimate in pomodori" do
      raw_data = create_notification(data: { 'text' => "@trackinguser [10p]" })
      Tracking.new(raw_data).estimate.amount.should == 5
    end

    it "fetch the estimate from a complex estimate message" do
      raw_data = create_notification(data: { 'text' => "@maxmazza Dobbiamo ancora lavorarci.\n@trackinguser ristimo ancora [3h] per il fix" })
      Tracking.new(raw_data).estimate.amount.should == 3.0
    end

    it "tracks the effort with the date given in the notification text, not the actual notification date" do
      raw_data = create_notification(
        data: { 'text' => "@trackinguser 22.11.2012 [6p]" },
      date: "2012-09-19T12:46:13.713Z")

      tracking = Tracking.new(raw_data)

      tracking.estimate.date.should == Date.parse('2012-11-22')
    end

  end

  describe "#effort?" do
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
    it "is nil when the notification does not contain an estimate" do
      Tracking.new(unrecognized_notification).effort.should be_nil
    end

    it "is the hour-based effort when the notification contains an effort in hours" do
      raw_data = create_notification(
        data: { 'text' => "@trackinguser +2h" },
        date: "2012-10-28T21:06:14.801Z",
      member_creator: stub(username: "pietrodibello"))

      Tracking.new(raw_data).effort.should == Effort.new(amount: 2.0, date: Date.parse('2012-10-28'), members: ["@pietrodibello"])
    end

    it "converts the effort in hours when the notification contains an effort in days" do
      Tracking.new(create_notification(data: { 'text' => "@trackinguser +1.5d" })).effort.amount.should == 8+4
      Tracking.new(create_notification(data: { 'text' => "@trackinguser +1.5g" })).effort.amount.should == 8+4
    end

    it "converts the effort in hours when the notification contains an effort in pomodori" do
      raw_data = create_notification(data: { 'text' => "@trackinguser +10p" })
      Tracking.new(raw_data).effort.amount.should == 5
    end

    it "fetch the effort from a complex effort message" do
      raw_data = create_notification(data: { 'text' => "@trackinguser ho speso +2h e spero che stavolta possiamo rilasciarla" })
      Tracking.new(raw_data).effort.amount.should == 2.0
    end

    it "computes the effort considering all the mentioned team mates in the message" do
      raw_data = create_notification(data: { 'text' => "@trackinguser +2h assieme a @michelepangrazzi e @alessandrodescovi" })
      Tracking.new(raw_data).effort.amount.should == 2.0 * 3
    end

    it "tracks all the team mates which spent that effort on the card" do
      raw_data = create_notification(data: { 'text' => "@trackinguser +2h assieme a @michelepangrazzi e @alessandrodescovi" },
                                     member_creator: stub(username: "pietrodibello"))
      Tracking.new(raw_data).effort.members.should == ["@michelepangrazzi", "@alessandrodescovi", "@pietrodibello"]
    end

    it "tracks the effort only on the team members listed between round brackets" do
      raw_data = create_notification(data: { 'text' => "@trackinguser +3p (@alessandrodescovi @michelevincenzi)" },
                                     member_creator: stub(username: "pietrodibello"))
      tracking = Tracking.new(raw_data)

      tracking.effort.members.should == ["@alessandrodescovi", "@michelevincenzi"]
      tracking.effort.amount.should == 1.5 * 2
    end

    it "does not have an effort when is an estimate" do
      raw_data = create_notification(data: { 'text' => "@trackinguser stimata [6h]" }, member_creator: stub(username: "pietrodibello"))

      tracking = Tracking.new(raw_data)

      tracking.effort.should be_nil
    end

    it "tracks the effort with the date given in the notification text, not the actual notification date" do
      raw_data = create_notification(
        data: { 'text' => "@trackinguser 22.11.2012 +6p" },
      date: "2012-09-19T12:46:13.713Z")

      tracking = Tracking.new(raw_data)

      tracking.effort.date.should == Date.parse('2012-11-22')
    end

  end

  def create_notification(custom_params)
    params = { data: { 'text' => "@trackinguser +2h" }, date: "2012-10-28T21:06:14.801Z", member_creator: stub(username: "pietrodibello") }
    params.merge!(custom_params)

    stub(data: params[:data], date: params[:date], member_creator: params[:member_creator]).as_null_object
  end

  def create_estimate(time_measurement)
    create_notification(data: { 'text' => "@trackinguser [1.5#{TIME_MEASUREMENTS[time_measurement]}]" })
  end

  def create_effort(time_measurement)
    create_notification(data: { 'text' => "@trackinguser +4.5#{TIME_MEASUREMENTS[time_measurement]}]" })
  end

end
