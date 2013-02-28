require 'spec_helper'

module Tracco
  module Tracking
    describe EffortTracking do

      describe "#effort" do

        %w{pietrodibello michelepangrazzi alessandrodescovi michelevincenzi}.each do |username|
          let(username.to_sym) { Member.new(username: username) }
        end

        before(:each) do
          Trello::Member.stub(:find).and_return(Member.new(username: "any"))
        end

        it "is nil when the notification does not contain an estimate" do
          with(unrecognized_notification) { |tracking| tracking.effort.should be_nil }
        end

        it "does not parse effort in minutes (e.g. +30m)" do
          with_message("@trackinguser +30m") { |tracking| tracking.effort.should be_nil }
        end

        it "is the hour-based effort when the notification contains an effort in hours" do
          Trello::Member.should_receive(:find).with("michelepangrazzi").and_return(michelepangrazzi)

          raw_data = create_notification(data: { 'text' => "@trackinguser +2h" },
                                         date: "2012-10-28T21:06:14.801Z",
                                         member_creator: stub(username: "michelepangrazzi"))

          Tracking::Factory.build_from(raw_data).effort.should == Effort.new(amount: 2.0, date: Date.parse('2012-10-28'), members: [michelepangrazzi])
        end

        it "converts the effort in hours when the notification contains an effort in days" do
          with_message("@trackinguser +1.5d") { |t| t.effort.amount.should == 8+4 }
          with_message("@trackinguser +1.5g") { |t| t.effort.amount.should == 8+4 }
        end

        it "converts the effort in hours when the notification contains an effort in pomodori" do
          with_message("@trackinguser +10p") { |t| t.effort.amount.should == 5}
        end

        it "fetch the effort from a complex effort message" do
          with_message "@trackinguser ho speso +2h e spero che stavolta possiamo rilasciarla" do |tracking|
            tracking.effort.amount.should == 2.0
          end
        end

        it "fetch the effort even when beween square brackets" do
          with_message "@trackinguser [+0.5h]" do |tracking|
            tracking.effort.amount.should == 0.5
          end
        end

        it "computes the effort considering all the mentioned team mates in the message" do
          with_message "@trackinguser +2h assieme a @michelepangrazzi e @alessandrodescovi" do |tracking|
            tracking.effort.amount.should == 2.0 * 3
          end
        end

        it "tracks all the team mates which spent that effort on the card" do
          %w{pietrodibello michelepangrazzi alessandrodescovi}.each do |username|
            Trello::Member.should_receive(:find).with(username).and_return(self.send(username))
          end

          notification = create_notification(data: { 'text' => "@trackinguser +2h assieme a @michelepangrazzi e @alessandrodescovi" },
                                             member_creator: stub(username: "pietrodibello"))
          with notification do |tracking|
            tracking.effort.members.should == [michelepangrazzi, alessandrodescovi, pietrodibello]
          end
        end

        it "tracks the effort only on the team members listed between round brackets" do
          %w{michelevincenzi alessandrodescovi}.each do |username|
            Trello::Member.should_receive(:find).with(username).and_return(self.send(username))
          end

          notification = create_notification(data: { 'text' => "@trackinguser +3p (@alessandrodescovi @michelevincenzi)" },
                                             member_creator: stub(username: "pietrodibello"))

          with notification do |tracking|
            tracking.effort.members.should == [alessandrodescovi, michelevincenzi]
            tracking.effort.amount.should == 1.5 * 2
          end
        end

        it "tracks the effort with the date given in the notification text, not the actual notification date" do
          raw_data = create_notification(data: { 'text' => "@trackinguser 22.11.2012 +6p" }, date: "2012-09-19T12:46:13.713Z")

          tracking = Tracking::Factory.build_from(raw_data)

          tracking.effort.date.should == Date.parse('2012-11-22')
        end

        it "tracks the effort to yesterday when the keyword 'yesterday' is present before the effort amount" do
          raw_data = create_notification(data: { 'text' => "@trackinguser yesterday +6p" }, date: "2012-09-19T12:46:13.713Z")

          tracking = Tracking::Factory.build_from(raw_data)

          tracking.effort.date.should == Date.parse('2012-09-18')
        end

        it "tracks the effort to yesterday when the keyword 'yesterday' is present before the effort amount" do
          raw_data = create_notification(data: { 'text' => "@trackinguser +6p yesterday" }, date: "2012-09-19T12:46:13.713Z")

          tracking = Tracking::Factory.build_from(raw_data)

          tracking.effort.date.should == Date.parse('2012-09-18')
        end

      end

    end
  end
end
