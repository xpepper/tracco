require 'spec_helper'
require 'mongoid-rspec'

describe Member do

  it { should have_fields(:trello_id, :username, :full_name, :avatar_id, :bio, :url) }
  it { should be_embedded_in(:effort) }

  describe "validation" do
    it { should validate_presence_of(:username) }
  end

  describe "equality" do
    it "is equal to another member with the same username" do
      member            = Member.new(username: "piero")
      same_member       = Member.new(username: "piero")
      different_member  = Member.new(username: "tommaso")

      member.should == same_member
      member.should_not == different_member
    end
  end

  describe ".build_from" do
    it "builds a Member from a Trello Member" do
      member = Member.build_from(Trello::Member.new("username" => "piero"))

      member.username.should == "piero"
    end

    it "takes the Trello Member id and set it as trello_id" do
      member = Member.build_from(Trello::Member.new("username" => "piero", "id" => "1234567abc"))

      member.id.should_not    == "1234567abc"
      member.trello_id.should == "1234567abc"
    end
  end

  describe "#effort_spent" do
    %w{piero tommaso}.each do |username|
      let(username.to_sym) { Member.new(username: username) }
    end

    let(:card)         { TrackedCard.create(name: "any", short_id: 1234, trello_id: "123123") }
    let(:another_card) { TrackedCard.create(name: "any_other", short_id: 1235, trello_id: "123125") }

    it "is zero when the member did not spent effort at all" do
      piero.effort_spent.should == 0
    end

    it "counts the effort spent on a card" do
      card.efforts << Effort.new(amount: 4, date: Date.today, members: [piero, tommaso])
      card.efforts << Effort.new(amount: 5, date: Date.today, members: [tommaso])

      piero.effort_spent.should == 4 / 2
    end

    it "counts the effort spent on several cards" do
      card.efforts << Effort.new(amount: 4, date: Date.today, members: [piero, tommaso])
      another_card.efforts << Effort.new(amount: 5, date: Date.today, members: [piero])

      piero.effort_spent.should == 2 + 5
    end

  end

  describe "#avatar_url" do
    it "points to the avatar thumbnail image" do
      member = Member.new(avatar_id: "123xyz")
      member.avatar_url.should == "https://trello-avatars.s3.amazonaws.com/123xyz/30.png"
    end
  end
end
