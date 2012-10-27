require 'trello'
require 'yaml'
require 'rainbow'


require_relative 'lib/trello_authorize'
require_relative 'lib/tracking'

include TrelloAuthorize
init_trello

puts "connected...".color(:green)
tracker = Member.find("trackinguser")
tracker.notifications.each do |notification|
  tracking = Tracking.new(notification)
  begin
    puts "[#{tracking.date}] From #{tracking.notifier.username.color(:green)} on card '#{tracking.card.name.color(:yellow)}': #{tracking.raw_text}"
  rescue => e
    puts "skipping tracking: #{e.message}".color(:red)
  end
end

# {"text"=>"@trackinguser stima: 1h", "card"=>{"name"=>"Cambio password  - spostare l'utente al bottom della page", "idShort"=>294, "id"=>"5087b32add671fb9770021fe"}, "board"=>{"name"=>"Iterazione settimanale", "id"=>"502514e6af0f584e241bf9ec"}}
#
# iteration = Board.find("502514e6af0f584e241bf9ec")
# iteration_steps = iteration.lists
# iteration_steps.each do |step|
#   puts step.name.upcase
#   step.cards.each do |user_story|
#     puts "\t" + user_story.name
#   end
# end
