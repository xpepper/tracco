require 'spec_helper'

require_relative '../lib/trello_authorize'
require_relative '../lib/tracking'
require_relative '../lib/trello_tracker'

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
        Tracking.new(create_estimate(time_measurement)).estimate?.should be_true
      end
    end

  end

  def create_estimate(time_measurement)
    stub(data: { 'text' => "@trackinguser [1.5#{TIME_MEASUREMENTS[time_measurement]}]" })
  end
end
