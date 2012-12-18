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
end
