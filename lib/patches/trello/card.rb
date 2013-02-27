# Reopening the Trello::Card class to add some helper methods
module Trello
  class Card

    # Tells whether a card is in a list with a name starting with "DONE"
    def in_done_column?
      list_name = ""
      begin
        list_name = list.name.strip
      rescue Trello::Error => e
        Trello::Logger.error("Cannot find column for card #{name}")
      end

      !!(list_name =~ /^DONE/i)
    end
  end

end


