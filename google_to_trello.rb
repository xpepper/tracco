# gem install google_drive
# gem install highline

require 'trello'
require "google_drive"
require 'highline/import'
require 'rainbow'


columns = {
  iteration:        1,
  project:          2,
  id:               3,
  user_story_name:  4,
  status:           5,
  planned_effort:   6,
  prev_spent:       7,
  total_effort:     8,
  notes:            9
}

def init_trello
  config = YAML.load_file("config/config.yml")

  developer_public_key = config["trello"]["developer_public_key"]
  access_token_key = config["trello"]["access_token_key"]
  developer_secret = config["trello"]["developer_secret"]

  include Trello
  include Trello::Authorization

  Trello::Authorization.const_set :AuthPolicy, OAuthPolicy

  OAuthPolicy.consumer_credential = OAuthCredential.new developer_public_key, developer_secret
  OAuthPolicy.token = OAuthCredential.new access_token_key, nil
end

def open_google_docs_session(default_email="pietro.dibello@xpeppers.com")
  username = ask("Enter google docs username: ") { |q| q.default = default_email }
  password = ask("Enter google docs password: ") { |q| q.echo = false }

  GoogleDrive.login(username, password)
end

init_trello
session = open_google_docs_session
puts "connected...".color(:green) if session

spreadsheet = session.spreadsheet_by_title("Backlog F3")
backlog = spreadsheet.worksheet_by_title("iterazioni")


status_list = []
iteration_number = 1
iteration = Board.find("4fd516de6c27075f3baf8b3d") # create(:name => "iterazione #{iteration_number}")

index = 3 # skip the headers
puts "looking for iteration #{iteration_number}".color(:red)

while backlog[index,columns[:iteration]] != iteration_number.to_s do
  puts backlog[index,columns[:iteration]]
  print ".".color(:red)
  index += 1
end

while backlog[index,columns[:iteration]] == iteration_number.to_s do
  print ".".color(:yellow)

  status = backlog[index,columns[:status]]
  if iteration.lists.map(&:name).include?(status)
    list = iteration.lists.detect {|l| l.name == status}
  else
    list = List.new("idBoard" => iteration.id)
    list.name = status
    list.save
  end

  Card.create(:list_id => list.id, :name => backlog[index,columns[:user_story_name]])

  index += 1
end

iteration.save

#
#
# index = 3 # skip the headers
# iteration_steps.each do |step|
#   step.cards.each do |user_story|
#     print ".".color(:green)
#     backlog[index,columns[:project]] = user_story.labels.map(&:name).join(" - ")
#     backlog[index,columns[:user_story_name]] = user_story.name
#     backlog[index,columns[:status]] = step.name
#     index += 1
#   end
# end
#
# backlog.save
puts "[DONE]".color(:green)