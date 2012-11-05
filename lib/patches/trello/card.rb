module Trello
  class Card
    def estimates
      @estimates ||= []
    end
    def efforts
      @efforts ||= []
    end
  end
end
