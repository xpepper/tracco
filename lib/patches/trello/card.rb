module Trello

  class Card
    # Reopening the Trello::Card class to add a  method detecting a card moved in a DONE column
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


