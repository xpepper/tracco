require 'spec_helper'

describe Trello::Card do

  describe "#in_done_column?" do

    let(:trello_card) { Trello::Card.new("name" => "a name", "desc" => "any description") }

    let(:todo_column) { Trello::List.new("name" => "ToDo") }
    let(:done_column) { Trello::List.new("name" => "Done yesterday") }

    it "is done when is in a DONE column" do
      trello_card.stub(:list).and_return(done_column)

      trello_card.in_done_column?.should be_true
    end

    it "is still not done when is not in DONE column" do
      trello_card.stub(:list).and_return(todo_column)

      trello_card.in_done_column?.should be_false
    end

    it "is false when the card cannot be found on Trello" do
      trello_card.stub(:list).and_raise(Trello::Error)
      trello_card.in_done_column?.should be_false
    end

  end
end
