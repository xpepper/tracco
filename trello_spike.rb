require 'trello'
require 'yaml'

config = YAML.load_file("config.yaml")

developer_public_key = config["trello"]["developer_public_key"]
access_token_key = config["trello"]["access_token_key"]
developer_secret = config["trello"]["developer_secret"]

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