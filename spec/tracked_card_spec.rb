require 'spec_helper'

describe TrackedCard do

  subject(:card) { TrackedCard.new(name: "any", short_id: 1234, trello_id: "123123") }

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

  describe ".with_trello_id" do
    before(:each) do
      TrackedCard.delete_all
    end
    after(:each) do
      TrackedCard.delete_all
    end

    it "find a card given its Trello id" do
      card = TrackedCard.create(name: "any card", short_id: 1234, trello_id: "1")
      another_card = TrackedCard.create(name: "another card", short_id: 3456, trello_id: "2")

      TrackedCard.with_trello_id("1").should == card
      TrackedCard.with_trello_id("3").should == nil
    end
  end

  it "has no estimates and efforts initially" do
    card.estimates.should be_empty
    card.efforts.should be_empty
  end

  it "is possible to add estimates" do
    card.estimates << Estimate.new(amount: 5, date: Date.today.prev_day)
    card.estimates << Estimate.new(amount: 12, date: Date.today)

    card.estimates.should have(2).estimates
  end

  it "is possible to add efforts" do
    card.efforts << Effort.new(amount: 3, date: Date.today, members: [piero, tommaso])
    card.efforts << Effort.new(amount: 5, date: Date.today, members: [tommaso])

    card.efforts.should have(2).efforts
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

  describe "#total_effort" do
    it "is zero when there's no effort" do
      card.total_effort.should == 0
    end

    it "computes the total effort on the card" do
      card.efforts << Effort.new(amount: 3, date: Date.today, members: [piero, tommaso])
      card.efforts << Effort.new(amount: 5, date: Date.today, members: [tommaso])

      card.total_effort.should == 3+5
    end
  end
  
  describe "#members" do
    it "lists all the members which spent some effort on the card" do
      card.efforts << Effort.new(amount: 3, date: Date.today, members: [piero, tommaso])
      card.efforts << Effort.new(amount: 5, date: Date.today, members: [tommaso])
      card.efforts << Effort.new(amount: 5, date: Date.today, members: [tommaso, michele])

      card.members.should == [piero, tommaso, michele]
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

  describe "#to_s" do
    before(:each) do
      Date.stub(:today).and_return(Date.parse("2012-11-05"))
    end

    it "describes the card as a string" do
      card = TrackedCard.new(name: "A Story Name")
      card.estimates << Estimate.new(amount: 5, date: Date.today)
      card.efforts << Effort.new(amount: 3, date: Date.today, members: [Member.new(username: "piero"),   Member.new(username: "tommaso")])
      card.efforts << Effort.new(amount: 6, date: Date.today, members: [Member.new(username: "piero"),   Member.new(username: "tommaso")])

      card.to_s.should == %Q{[A Story Name]. Total effort: 9.0h. Estimates ["[2012-11-05] estimated 5.0 hours"]. Efforts: ["[2012-11-05] spent 3.0 hours by @piero, @tommaso", "[2012-11-05] spent 6.0 hours by @piero, @tommaso"]}

    end
  end

end
