require 'trello'

developer_public_key = "6742c2a79a7b5f2a86669609b09c4698"
access_token_key = "d141b6bec9b827a55c58081926ddf33e7ad527b8b48db8eb54f5163212ac8b1f"
developer_secret = "e50da76784459f5d8d40363628182536ae5be7a11a8f21a24023adb44b843b77"

include Trello
include Trello::Authorization

Trello::Authorization.const_set :AuthPolicy, OAuthPolicy

OAuthPolicy.consumer_credential = OAuthCredential.new developer_public_key, developer_secret
OAuthPolicy.token = OAuthCredential.new access_token_key, nil

team = Organization.find("futur3")
team.boards.each do |board|
  puts board.name
end

iteration = Board.find("4fcc65eafb87c03a2152a67e")
iteration_steps = iteration.lists
iteration_steps.each do |step|
  puts step.name.upcase
  step.cards.each do |user_story| 
    puts "\t" + user_story.name
  end
end