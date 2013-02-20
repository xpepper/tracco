require 'spec_helper'

describe TrackedCard do

  before(:each) do
    Date.stub(:today).and_return(Date.parse("2012-11-05"))
  end

  subject(:card) { build(:tracked_card) }

  %w{piero tommaso michele}.each do |username|
    let(username.to_sym) { Member.new(username: username) }
  end

  describe "validations" do
    it "is not valid when a name is not given" do
      TrackedCard.new(trello_id: "123456789", short_id: 1234).should_not be_valid
    end

    it "is not valid when a short_id is not given" do
      TrackedCard.new(name: "any", trello_id: "123456789").should_not be_valid
    end

    it "is not valid when a trello_id is not given" do
      TrackedCard.new(name: "any", short_id: 1234).should_not be_valid
    end

    it "is valid when has a name, a short id and a trello id" do
      TrackedCard.new(name: "any", trello_id: "123456789", short_id: 1234).should be_valid
    end
  end

  describe ".find_by_trello_id" do
    it "finds a card given its Trello id" do
      card = create(:tracked_card, trello_id: "1")
      another_card = create(:tracked_card, trello_id: "2")

      TrackedCard.find_by_trello_id("1").should == card
      TrackedCard.find_by_trello_id("3").should == nil
    end
  end

  describe ".all_tracked_cards" do
    let!(:card)          { create(:tracked_card, name: "AAA", estimates: [build(:estimate)], efforts: [build(:effort)]) }
    let!(:another_card)  { create(:tracked_card, name: "ZZZ", estimates: [build(:estimate)], efforts: [build(:effort)]) }
    let!(:card_without_tracking) { create(:tracked_card) }

    it "finds all tracked cards with a valid tracking" do
      TrackedCard.all_tracked_cards.should == [card, another_card]
    end

    it "optionally sorts the cards using a given sorting method" do
      card.update_attributes(name: "AAA")
      another_card.update_attributes(name: "ZZZ")

      TrackedCard.all_tracked_cards(:method => :name).should == [card, another_card]
    end

    it "applies an optional sorting order" do
      card.update_attributes(name: "AAA")
      another_card.update_attributes(name: "ZZZ")

      card_without_tracking = create(:tracked_card)

      TrackedCard.all_tracked_cards(:method => :name, :order => :desc).should == [another_card, card]
    end

    it "uses the ascending order as default sorting order option" do
      card.update_attributes(name: "AAA", short_id: 44)
      another_card.update_attributes(name: "ZZZ", short_id: 11)
      card_without_tracking.update_attributes(short_id: 3456)

      TrackedCard.all_tracked_cards(:method => :short_id).should == [another_card, card]
    end

  end

  describe ".update_or_create_with" do
    let(:trello_card) { Trello::Card.new("id" => "ABC123", "name" => "a name", "idShort" => 1, "desc" => "any description") }

    before(:each) do
      Trello::Card.any_instance.stub(:in_done_column?)
    end

    it "creates a tracked card on a given trello card" do
      tracked_card = TrackedCard.update_or_create_with(trello_card)

      tracked_card.name.should == "a name"
      tracked_card.trello_id == "ABC123"
      tracked_card.short_id == 1
    end

    it "updates an existing tracked card on a given trello card" do
      existing_card = create(:tracked_card, name: "an old name", trello_id: trello_card.id)

      updated_card = TrackedCard.update_or_create_with(trello_card)

      updated_card.should == existing_card
      updated_card.name.should == "a name"
    end

    it "is nil when the trello card is not valid" do
      invalid_trello_card = Trello::Card.new("id" => nil, "name" => nil)

      TrackedCard.update_or_create_with(invalid_trello_card).should be_nil
      TrackedCard.all.should be_empty
    end

    it "tracks the card as done when the original trello card is moved in a DONE column" do
      trello_card.stub(:in_done_column?).and_return(true)

      tracked_card = TrackedCard.update_or_create_with(trello_card)

      tracked_card.should be_done
    end

    it "tracks the card as NOT done when the original trello card is moved in a column different from DONE" do
      trello_card.stub(:in_done_column?).and_return(false)

      tracked_card = TrackedCard.update_or_create_with(trello_card)

      tracked_card.should_not be_done
    end

  end

  describe ".build_from" do
    it "builds a TrackedCard from a Trello Card" do
      tracked_card = TrackedCard.build_from(Trello::Card.new("name" => "a name", "desc" => "any description"))

      tracked_card.name.should == "a name"
      tracked_card.description.should == "any description"
    end

    it "takes the Trello Card id and set it as trello_id" do
      tracked_card = TrackedCard.build_from(Trello::Card.new("id" => "abc123", "name" => "a name", "desc" => "any description"))

      tracked_card.id.should_not    == "abc123"
      tracked_card.trello_id.should == "abc123"
    end

  end

  it "has no estimates and efforts initially" do
    card.estimates.should be_empty
    card.efforts.should be_empty
  end

  it "is possible to add estimates" do
    card.estimates << build(:estimate) << build(:estimate)
    card.estimates.should have(2).estimates
  end

  it "is possible to add efforts" do
    card.efforts << build(:effort) << build(:effort)
    card.efforts.should have(2).efforts
  end

  describe "#trello_notifications" do
    let(:first_notification)   { stub("notification1", date: Date.yesterday) }
    let(:second_notification)  { stub("notification1", date: Date.today)     }

    it "fetch all the card notifications from trello" do
      card.estimates << Estimate.new(tracking_notification_id: "xyz987", amount: 5, date: Date.yesterday)
      card.efforts << Effort.new(tracking_notification_id: "abc123", amount: 3, date: Date.today, members: [piero])

      Trello::Notification.should_receive(:find).with("xyz987").and_return(second_notification)
      Trello::Notification.should_receive(:find).with("abc123").and_return(first_notification)
      card.trello_notifications.should == [first_notification, second_notification]
    end
  end

  describe "equality" do
    it "is equal to another TrelloCard when the trello id is the same" do
      card          = TrackedCard.new(name: "a name", trello_id: "123456789")
      same_card     = TrackedCard.new(name: "a name", trello_id: "123456789")
      another_card  = TrackedCard.new(name: "a name", trello_id: "987654321")

      card.should == same_card
      card.should_not == another_card
    end
  end

  describe "#add" do
    let(:card) { build(:tracked_card) }
    let(:estimate_tracking) { Tracking::EstimateTracking.new(create_notification(data: { 'text' => "@trackinguser [1h]" })) }

    it "adds an estimate from a tracking estimate notification" do
      card.add(estimate_tracking)
      card.estimates.should have(1).estimate
    end

    it "adds an estimate only once" do
      card.add(estimate_tracking)
      card.add(estimate_tracking)

      card.estimates.should have(1).estimate
    end

    it "is done when has a DONE notification" do
      card.should_not be_done

      card.add(Tracking::CardDoneTracking.new(stub(:notification)))
      card.should be_done
    end

  end

  describe "#add!" do
    let(:card) { build(:tracked_card) }

    it "saves the tracked card after adding the tracking" do
      any_tracking = Tracking::EstimateTracking.new(create_notification(data: { 'text' => "@trackinguser [1h]" }))

      card.add!(any_tracking)
      card.reload.should_not be_nil
    end
  end

  describe "#total_effort" do
    it "is zero when there's no effort" do
      card.total_effort.should == 0
    end

    it "computes the total effort on the card" do
      card.efforts << build(:effort, amount: 3)
      card.efforts << build(:effort, amount: 5)

      card.total_effort.should == 3+5
    end
  end

  describe "#last_estimate_error" do
    it "is nil when the card has no estimate" do
      card.efforts << build(:effort, amount: 5)

      card.last_estimate_error.should be_nil
    end

    it "is nil when the card has no effort" do
      card.efforts << build(:estimate)

      card.last_estimate_error.should be_nil
    end

    it "is zero when actual effort is equal to estimate" do
      card.estimates << build(:estimate, amount: 5)
      card.efforts << build(:effort, amount: 5)

      card.last_estimate_error.should == 0.0
    end

    it "is 100 when the actual effort is twice the given estimate" do
      card.estimates << build(:estimate, amount: 5)
      card.efforts << build(:effort, amount: 10)

      card.last_estimate_error.should == 100.0
    end

    it "is -50 when the actual effort is half of the given estimate" do
      card.estimates << build(:estimate, amount: 10)
      card.efforts << build(:effort, amount: 5)

      card.last_estimate_error.should == -50.0
    end

    it "is rounded with two decimal digits" do
      card.estimates << build(:estimate, amount: 3)
      card.efforts << build(:effort, amount: 5)

      card.last_estimate_error.should == 66.67
    end

    describe "#estimate_errors" do

      it "collects all the estimate errors against the actual effort" do
        card.estimates << Estimate.new(amount: 5, date: Date.yesterday)
        card.efforts << Effort.new(amount: 10, date: Date.yesterday, members: [tommaso])

        card.estimates << Estimate.new(amount: 10, date: Date.today)
        card.efforts << Effort.new(amount: 5, date: Date.today, members: [tommaso])

        card.estimate_errors.should == [200.0, 50.0]
      end
    end

  end

  describe "#members" do
    it "lists all the members which spent some effort on the card" do
      card.efforts << build(:effort, members: [piero, tommaso])
      card.efforts << build(:effort, members: [tommaso])
      card.efforts << build(:effort, members: [tommaso, michele])

      card.members.should == [piero, tommaso, michele]
    end
  end

  describe "#working_start_date" do

    it "is the date of the first effort spent on the card" do
      card.efforts << build(:effort, date: Date.today)
      card.efforts << build(:effort, date: Date.yesterday)
      card.efforts << build(:effort, date: Date.tomorrow)

      card.working_start_date.should == Date.yesterday
    end
  end

  describe "#first_activity_date" do
    it "is the date of the first effort or estimate given on the card" do
      card.estimates << build(:estimate, date: Date.yesterday)
      card.estimates << build(:estimate, date: Date.yesterday.prev_day)
      card.estimates << build(:estimate, date: Date.tomorrow)

      card.efforts << build(:effort, date: Date.yesterday)
      card.efforts << build(:effort, date: Date.today)

      card.first_activity_date.should == Date.yesterday.prev_day
    end
  end

  describe "#first_estimate_date" do
    it "is the date of the first estimate given on the card" do
      card.estimates << build(:estimate, date: Date.tomorrow)
      card.estimates << build(:estimate, date: Date.yesterday.prev_day)
      card.estimates << build(:estimate, date: Date.today)

      card.first_estimate_date.should == Date.yesterday.prev_day
    end
  end

  describe "#last_estimate_date" do
    it "is the date of the last estimate given on the card" do
      card.estimates << build(:estimate, date: Date.yesterday)
      card.estimates << build(:estimate, date: Date.tomorrow)
      card.estimates << build(:estimate, date: Date.today)

      card.last_estimate_date.should == Date.tomorrow
    end
  end

  describe "#no_tracking?" do
    it "is false when there's no effort or estimate tracked on the card" do
      card.no_tracking?.should be_true

      card.estimates << build(:estimate, date: Date.yesterday)
      card.no_tracking?.should be_false
    end
  end

  describe "#to_s" do
    it "describes the card as a string" do
      card = TrackedCard.new(name: "A Story Name")
      card.estimates << Estimate.new(amount: 5, date: Date.today)
      card.efforts << Effort.new(amount: 3, date: Date.today, members: [Member.new(username: "piero"), Member.new(username: "tommaso")])
      card.efforts << Effort.new(amount: 6, date: Date.today, members: [Member.new(username: "piero"), Member.new(username: "tommaso")])

      card.to_s.should == %Q{[A Story Name]. Total effort: 9.0h. Estimates ["[2012-11-05] estimated 5.0 hours"]. Efforts: ["[2012-11-05] spent 3.0 hours by @piero, @tommaso", "[2012-11-05] spent 6.0 hours by @piero, @tommaso"]}
    end
  end

  describe "#status" do
    it "is done when is done" do
      done_card = TrackedCard.new(done: true)
      done_card.status.should == :done

      done_card.efforts << build(:effort)
      done_card.status.should == :done
    end

    it "is todo when no effort has been spent on the card" do
      card = TrackedCard.new
      card.status.should == :todo

      card.efforts << build(:effort)
      card.status.should == :in_progress
    end
  end

end
