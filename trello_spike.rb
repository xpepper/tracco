require 'trello'
require 'yaml'

config = YAML.load_file("config.yml")

developer_public_key = config["trello"]["developer_public_key"]
access_token_key = config["trello"]["access_token_key"]
developer_secret = config["trello"]["developer_secret"]

include Trello
include Trello::Authorization

Trello::Authorization.const_set :AuthPolicy, OAuthPolicy

OAuthPolicy.consumer_credential = OAuthCredential.new developer_public_key, developer_secret
OAuthPolicy.token = OAuthCredential.new access_token_key, nil

team = Organization.find("futur3new")
team.boards.each do |board|
  puts board.name
end

me = Member.find("trackinguser")
me.notifications.each do |n|
  p n
end
# 
# iteration = Board.find("502514e6af0f584e241bf9ec")
# iteration_steps = iteration.lists
# iteration_steps.each do |step|
#   puts step.name.upcase
#   step.cards.each do |user_story| 
#     puts "\t" + user_story.name
#   end
# end
