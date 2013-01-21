class CardDoneTracking
  include Tracking

  def add_to(card)
    card.done = true
  end

end
